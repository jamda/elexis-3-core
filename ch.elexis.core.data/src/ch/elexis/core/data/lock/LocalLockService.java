package ch.elexis.core.data.lock;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

import org.eclipse.core.runtime.Status;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.eclipsesource.jaxrs.consumer.ConsumerFactory;

import ch.elexis.core.data.activator.CoreHub;
import ch.elexis.core.data.constants.ElexisSystemPropertyConstants;
import ch.elexis.core.data.events.ElexisEvent;
import ch.elexis.core.data.events.ElexisEventDispatcher;
import ch.elexis.core.data.status.ElexisStatus;
import ch.elexis.core.lock.ILocalLockService;
import ch.elexis.core.lock.types.LockInfo;
import ch.elexis.core.lock.types.LockRequest;
import ch.elexis.core.lock.types.LockResponse;
import ch.elexis.core.model.IPersistentObject;
import ch.elexis.core.server.ILockService;
import ch.elexis.data.PersistentObject;
import ch.elexis.data.User;

/**
 * ILocalLockService implementation. Managing locks of PersistentObjects.</br>
 * If the environment variable <b>ELEXIS_SERVER_REST_INTERFACE_URL</b> is set a connection to a
 * remote LockService will used internal.
 * 
 * @author marco
 *
 */
public class LocalLockService implements ILocalLockService {

	private ILockService ils;

	private HashMap<String, LockInfo> locks = new HashMap<String, LockInfo>();
	private final boolean standalone;
	private Logger log = LoggerFactory.getLogger(LocalLockService.class);

	/**
	 * A unique id for this instance of Elexis. Changes on every restart
	 */
	private static final UUID systemUuid = UUID.randomUUID();

	/**
	 * Construct a new LocalLockService. Application code should access via
	 * {@link CoreHub#getLocalLockService()} and <b>NOT</b> create its own instance.
	 * 
	 */
	public LocalLockService(){
		final String restUrl = System.getProperty(ElexisSystemPropertyConstants.ELEXIS_SERVER_REST_INTERFACE_URL);
		if (restUrl != null) {
			standalone = false;
			log.info("Operating against elexis-server instance on " + restUrl);
			ils = ConsumerFactory.createConsumer(restUrl, ILockService.class);
		} else {
			standalone = true;
			log.info("Operating in stand-alone mode.");
		}
	}

	@Override
	public LockResponse releaseAllLocks() {
		if (standalone) {
			return LockResponse.OK;
		}

		List<LockInfo> lockList = new ArrayList<LockInfo>(locks.values());
		for (LockInfo lockInfo : lockList) {
			LockRequest lockRequest = new LockRequest(LockRequest.Type.RELEASE, lockInfo);
			LockResponse lr = acquireOrReleaseLocks(lockRequest);
			if (!lr.isOk()) {
				return lr;
			}
		}
		return LockResponse.OK;
	}

	@Override
	public LockResponse releaseLock(IPersistentObject po){
		if (po == null) {
			return LockResponse.DENIED(null);
		}
		return releaseLock(po.storeToString());
	}

	private LockResponse releaseLock(String storeToString){
		User user = (User) ElexisEventDispatcher.getSelected(User.class);
		LockInfo lil =
			LockStrategy.createLockInfoList(storeToString, user.getId(), systemUuid.toString());
		LockRequest lockRequest = new LockRequest(LockRequest.Type.RELEASE, lil);
		return acquireOrReleaseLocks(lockRequest);
	}
	
	@Override
	public LockResponse acquireLock(IPersistentObject po){
		if (po == null) {
			return LockResponse.DENIED(null);
		}
		return acquireLock(po.storeToString());
	}
	
	private LockResponse acquireLock(String storeToString){
		if (storeToString == null) {
			return LockResponse.DENIED(null);
		}
		
		User user = (User) ElexisEventDispatcher.getSelected(User.class);
		LockInfo lockInfo = new LockInfo(storeToString, user.getId(), systemUuid.toString());
		LockRequest lockRequest = new LockRequest(LockRequest.Type.ACQUIRE, lockInfo);
		return acquireOrReleaseLocks(lockRequest);
	}
	
	@Override
	public LockResponse acquireOrReleaseLocks(LockRequest lockRequest){
		if (standalone) {
			return LockResponse.OK;
		}

		if (ils == null) {
			String message = "System not configured for standalone mode, and elexis-server not available!";
			log.error(message);
			ElexisEventDispatcher.fireElexisStatusEvent(
					new ElexisStatus(Status.ERROR, CoreHub.PLUGIN_ID, ElexisStatus.CODE_NONE, message, null));
			return LockResponse.ERROR;
		}

		LockInfo lockInfo = lockRequest.getLockInfo();

		synchronized (locks) {
			// does the requested lock match the cache on our side?
			if (LockRequest.Type.ACQUIRE == lockRequest.getRequestType()
					&& locks.keySet().contains(lockInfo.getElementId())) {
				return LockResponse.OK;
			}

			// TODO should we release all locks on acquiring a new one?
			// if yes, this has to be dependent upon the strategy
			try {
				LockResponse lr = ils.acquireOrReleaseLocks(lockRequest);
				if (!lr.isOk()) {
					return lr;
				}

				if (LockRequest.Type.ACQUIRE == lockRequest.getRequestType()) {
					// ACQUIRE ACTIONS
					// lock is granted only if we have non-exception on acquire
					locks.put(lockInfo.getElementId(), lockInfo);

					PersistentObject po = CoreHub.poFactory.createFromString(lockInfo.getElementStoreToString());
					ElexisEventDispatcher.getInstance()
							.fire(new ElexisEvent(po, po.getClass(), ElexisEvent.EVENT_LOCK_AQUIRED));

				}
			} catch (Exception e) {
				// if we have an exception here, our lock copies never get
				// deleted!!!
				String message = "Error trying to acquireOrReleaseLocks.";
				log.error(message);
				ElexisEventDispatcher.fireElexisStatusEvent(
						new ElexisStatus(Status.ERROR, CoreHub.PLUGIN_ID, ElexisStatus.CODE_NONE, message, e));
				return LockResponse.ERROR;
			} finally {
				if (LockRequest.Type.RELEASE.equals(lockRequest.getRequestType())) {
					// RELEASE ACTIONS
					// releases are also to be performed on occurence of an
					// exception
					locks.remove(lockInfo.getElementId());

					PersistentObject po = CoreHub.poFactory.createFromString(lockInfo.getElementStoreToString());
					ElexisEventDispatcher.getInstance()
							.fire(new ElexisEvent(po, po.getClass(), ElexisEvent.EVENT_LOCK_RELEASED));

				}
			}

			return LockResponse.OK;
		}
	}

	@Override
	public boolean isLocked(IPersistentObject po){
		return isLocked(po.storeToString());
	}
	
	@Override
	public boolean isLocked(String storeToString){
		if (storeToString == null) {
			return false;
		}
		
		if (standalone) {
			return true;
		}
		// check local locks first
		if(locks.containsKey(LockInfo.getElementId(storeToString))) {
			return true;
		}
		
		return ils.isLocked(storeToString);
	}

	@Override
	public LockInfo getLockInfo(String storeToString){
		String elementId = LockInfo.getElementId(storeToString);
		LockInfo lockInfo = locks.get(elementId);
		return lockInfo;
	}
}