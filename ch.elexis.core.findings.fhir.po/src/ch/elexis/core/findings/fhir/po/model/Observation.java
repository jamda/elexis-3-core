package ch.elexis.core.findings.fhir.po.model;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import ch.elexis.core.findings.IEncounter;
import ch.elexis.core.findings.IObservation;
import ch.elexis.data.PersistentObject;
import ch.rgw.tools.VersionInfo;

public class Observation extends AbstractFhirPersistentObject implements IObservation {
	
	protected static final String TABLENAME = "CH_ELEXIS_CORE_FINDINGS_OBSERVATION";
	protected static final String VERSION = "1.0.0";
	
	public static final String FLD_PATIENTID = "patientid"; //$NON-NLS-1$
	public static final String FLD_ENCOUNTERID = "encounterid"; //$NON-NLS-1$
	public static final String FLD_PERFORMERID = "performerid"; //$NON-NLS-1$
	
	//@formatter:off
	protected static final String createDB =
	"CREATE TABLE " + TABLENAME + "(" +
	"ID					VARCHAR(25) PRIMARY KEY," +
	"lastupdate 		BIGINT," +
	"deleted			CHAR(1) default '0'," + 
	"patientid	        VARCHAR(80)," +
	"encounterid	    VARCHAR(80)," +
	"performerid	    VARCHAR(80)," +
	"content      		TEXT" + ");" + 
	"CREATE INDEX CH_ELEXIS_CORE_FINDINGS_OBSERVATION_IDX1 ON " + TABLENAME + " (patientid);" +
	"CREATE INDEX CH_ELEXIS_CORE_FINDINGS_OBSERVATION_IDX2 ON " + TABLENAME + " (encounterid);" +
	"INSERT INTO " + TABLENAME + " (ID, " + FLD_PATIENTID + ") VALUES ('VERSION','" + VERSION + "');";
	//@formatter:on
	
	static {
		addMapping(TABLENAME, FLD_PATIENTID, FLD_ENCOUNTERID, FLD_PERFORMERID, FLD_CONTENT);
		
		Observation version = load("VERSION");
		if (version.state() < PersistentObject.DELETED) {
			createOrModifyTable(createDB);
		} else {
			VersionInfo vi = new VersionInfo(version.get(FLD_PATIENTID));
			if (vi.isOlder(VERSION)) {
				// we should update eg. with createOrModifyTable(update.sql);
				// And then set the new version
				version.set(FLD_PATIENTID, VERSION);
			}
		}
	}
	
	public static Observation load(final String id){
		return new Observation(id);
	}
	
	protected Observation(final String id){
		super(id);
	}
	
	public Observation(){}
	
	@Override
	public String getLabel(){
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	protected String getTableName(){
		return TABLENAME;
	}
	
	@Override
	public Optional<IEncounter> getEncounter(){
		return getEncounter(FLD_ENCOUNTERID);
	}
	
	@Override
	public void setEncounter(IEncounter encounter){
		setEncounter(encounter, FLD_ENCOUNTERID);
	}
	
	@Override
	public String getPatientId(){
		return get(FLD_PATIENTID);
	}
	
	@Override
	public void setPatientId(String patientId){
		set(FLD_PATIENTID, patientId);
	}
	
	@Override
	public List<IObservation> getSourceObservations(){
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	public void addSourceObservation(IObservation source){
		// TODO Auto-generated method stub
		
	}
	
	@Override
	public List<IObservation> getTargetObseravtions(){
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	public void addTargetObservation(IObservation source){
		// TODO Auto-generated method stub
		
	}
	
	@Override
	public Optional<LocalDateTime> getEffectiveTime(){
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	public void setEffectiveTime(LocalDateTime time){
		// TODO Auto-generated method stub
		
	}
}
