/*******************************************************************************
 * Copyright (c) 2005-2009, G. Weirich and Elexis
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    G. Weirich - initial implementation
 *    
 *******************************************************************************/

package ch.elexis.data;

import static ch.elexis.core.model.LabResultConstants.PATHOLOGIC;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import ch.elexis.core.constants.Preferences;
import ch.elexis.core.constants.StringConstants;
import ch.elexis.core.data.activator.CoreHub;
import ch.elexis.core.data.beans.ContactBean;
import ch.elexis.core.exceptions.ElexisException;
import ch.elexis.core.jdt.Nullable;
import ch.elexis.core.model.IContact;
import ch.elexis.core.model.ILabItem;
import ch.elexis.core.model.ILabResult;
import ch.elexis.core.model.IPatient;
import ch.elexis.core.types.Gender;
import ch.elexis.core.types.LabItemTyp;
import ch.rgw.tools.ExHandler;
import ch.rgw.tools.StringTool;
import ch.rgw.tools.TimeTool;

public class LabResult extends PersistentObject implements ILabResult {
	public static final String LABRESULT_UNSEEN = "Labresult:unseen"; //$NON-NLS-1$
	public static final String DATE = "Datum"; //$NON-NLS-1$
	public static final String TIME = "Zeit"; //$NON-NLS-1$
	public static final String FLAGS = "Flags"; //$NON-NLS-1$
	public static final String COMMENT = "Kommentar"; //$NON-NLS-1$
	public static final String RESULT = "Resultat"; //$NON-NLS-1$
	public static final String ITEM_ID = "ItemID"; //$NON-NLS-1$
	public static final String PATIENT_ID = "PatientID"; //$NON-NLS-1$
	
	public static final String EXTINFO = "ExtInfo"; //$NON-NLS-1$
	public static final String UNIT = "unit"; //$NON-NLS-1$
	public static final String ANALYSETIME = "analysetime"; //$NON-NLS-1$
	public static final String OBSERVATIONTIME = "observationtime"; //$NON-NLS-1$
	public static final String TRANSMISSIONTIME = "transmissiontime"; //$NON-NLS-1$
	public static final String REFMALE = "refmale"; //$NON-NLS-1$
	public static final String REFFEMALE = "reffemale"; //$NON-NLS-1$
	public static final String ORIGIN_ID = "OriginID"; //$NON-NLS-1$
	
	public static final String EXTINFO_HL7_SUBID = "Hl7SubId";
	
	private static final String TABLENAME = "LABORWERTE"; //$NON-NLS-1$
	private final String SMALLER = "<";
	private final String BIGGER = ">";
	
	private static Pattern refValuesPattern = Pattern.compile("\\((.*?)\\)"); //$NON-NLS-1$
	private static String[] VALID_ABS_VALUES = new String[] {
		"positiv", "negativ", "pos.", "neg.", "pos", "neg", ">0", "<0"
	};
	
	private static final String QUERY_GROUP_ORDER;
	
	@Override
	protected String getTableName(){
		return TABLENAME;
	}
	
	static {
		addMapping(TABLENAME, PATIENT_ID, DATE_COMPOUND, ITEM_ID, RESULT, COMMENT, FLAGS,
			"Quelle=Origin", TIME, UNIT, ANALYSETIME, OBSERVATIONTIME, TRANSMISSIONTIME, REFMALE, //$NON-NLS-1$
			REFFEMALE, ORIGIN_ID);
		
		StringBuilder sb = new StringBuilder();
		sb.append("SELECT LW.ID, LW." + OBSERVATIONTIME + ", LW." + DATE + ", LW." + TIME + ", ");
		sb.append("LI." + LabItem.GROUP + ", LI." + LabItem.SHORTNAME + " ");
		sb.append("FROM " + TABLENAME + " AS LW LEFT JOIN ");
		sb.append(LabItem.LABITEMS + " AS LI ON LW." + ITEM_ID + "=LI.ID ");
		sb.append("WHERE LW." + PATIENT_ID + " LIKE ? AND LW.DELETED = '0'");
		QUERY_GROUP_ORDER = sb.toString();
	}
	
	protected LabResult(){}

	protected LabResult(final String id){
		super(id);
	}

	/**
	 * @since 3.2
	 */
	public LabResult(IPatient p, TimeTool date, ILabItem item, String result, String comment,
		IContact origin){
		create(null);
		String[] fields = {
			PATIENT_ID, DATE, ITEM_ID, RESULT, COMMENT
		};
		String[] vals =
			new String[] {
				p.getId(),
				date == null ? new TimeTool().toString(TimeTool.DATE_GER) : date
					.toString(TimeTool.DATE_GER), item.getId(), result, comment
			};
		set(fields, vals);
		// do we have an initial reference value?
		
		int flags = isPathologic(p.getGender(), item, result) ? PATHOLOGIC : 0;
		set(FLAGS, Integer.toString(flags));
		
		// do we have an initial origin (sending facility)
		if (origin != null) {
			set(ORIGIN_ID, origin.getId());
		} else {
			set(ORIGIN_ID, "");
		}
		addToUnseen();
	}

	/**
	 * Creates a new LabResult. If the type is numeric, a pathologic check will be applied.
	 * 
	 * @param p
	 * @param date
	 * @param item
	 * @param result
	 * @param comment
	 * @param refVal
	 *            valid for gender of {@link Patient} p
	 * @param origin
	 *            sending facility
	 * @since 3.1
	 */
	public LabResult(final Patient p, final TimeTool date, final ILabItem item, final String result,
		final String comment, @Nullable String refVal, @Nullable
		final Kontakt origin){
		create(null);
		String[] fields = {
			PATIENT_ID, DATE, ITEM_ID, RESULT, COMMENT
		};
		String[] vals =
			new String[] {
				p.getId(),
				date == null ? new TimeTool().toString(TimeTool.DATE_GER) : date
					.toString(TimeTool.DATE_GER), item.getId(), result, comment
			};
		set(fields, vals);
		// do we have an initial reference value?
		if (refVal != null) {
			if (Person.MALE.equalsIgnoreCase(p.getGeschlecht())) {
				setRefMale(refVal);
			} else {
				setRefFemale(refVal);
			}
		}
		
		int flags = isPathologic(p.getGender(), item, result) ? PATHOLOGIC : 0;
		set(FLAGS, Integer.toString(flags));
		
		// do we have an initial origin (sending facility)
		if (origin != null) {
			setOrigin(origin);
		}
		addToUnseen();
	}
	
	/**
	 * create a new LabResult. If the type is numeric, we'll check whether it's pathologic
	 */
	public LabResult(final Patient p, final TimeTool date, final LabItem item, final String result,
		final String comment){
		this(p, date, item, result, comment, null, null);
	}
	
	/**
	 * Create a new LabResult and set the origin
	 */
	public LabResult(final Patient p, final TimeTool date, final LabItem item, final String result,
		final String comment, final Kontakt origin){
		this(p, date, item, result, comment, null, origin);
	}
	
	private boolean isPathologic(final Gender g, final ILabItem item, final String result){
		if (item.getTyp().equals(LabItemTyp.ABSOLUTE)) {
			if (result.toLowerCase().startsWith("pos")) { //$NON-NLS-1$
				return true;
			}
			if (result.trim().startsWith("+")) { //$NON-NLS-1$
				return true;
			}
		} else /* if(item.getTyp().equals(LabItem.typ.NUMERIC)) */{
			String nr;
			if (g == Gender.MALE) {
				nr = getRefMale();
				if (nr == null || nr.isEmpty()) {
					nr = item.getReferenceMale();
				}
			} else {
				nr = getRefFemale();
				if (nr == null || nr.isEmpty()) {
					nr = item.getReferenceFemale();
				}
			}
			List<String> refStrings = parseRefString(nr);
			// only test first string as range is defined in one string
			if (!refStrings.isEmpty() && result != null) {
				return testRef(refStrings.get(0), result);
			}
		}
		return false;
	}
	
	public boolean isLongText(){
		if (getItem().getTyp() == LabItemTyp.TEXT && getResult().equalsIgnoreCase("text")
			&& !getComment().isEmpty()) {
			return true;
		}
		
		return false;
	}
	
	private boolean testRef(String ref, String result){
		try {
			if (ref.trim().startsWith(SMALLER) || ref.trim().startsWith(BIGGER)) {
				String resultSign = null;
				double refVal = Double.parseDouble(ref.substring(1).trim());
				
				if (result.trim().startsWith(SMALLER) || result.trim().startsWith(BIGGER)) {
					resultSign = result.substring(0, 1).trim();
					result = result.substring(1).trim();
				}
				double val = Double.parseDouble(result);
				if (ref.trim().startsWith(SMALLER)) {
					if (val >= refVal && !(val == refVal && SMALLER.equals(resultSign))) {
						return true;
					}
				} else {
					if (val <= refVal && !(val == refVal && BIGGER.equals(resultSign))) {
						return true;
					}
				}
			} else {
				String[] range = ref.split("\\s*-\\s*"); //$NON-NLS-1$
				if (range.length == 2) {
					double lower = Double.parseDouble(range[0]);
					double upper = Double.parseDouble(range[1]);
					double val = Double.parseDouble(result);
					if ((val < lower) || (val > upper)) {
						return true;
					}
				}
			}
		} catch (NumberFormatException nfe) {
			// don't mind
		}
		return false;
	}
	
	private static List<String> parseRefString(String ref){
		List<String> result = new ArrayList<String>();
		
		Matcher m = refValuesPattern.matcher(ref);
		
		while (m.find()) {
			result.add(m.group(1).trim());
		}
		
		// add the whole string if nothing found
		if (result.isEmpty()) {
			result.add(ref.trim());
		}
		
		return result;
	}
	
	public static LabResult load(final String id){
		return new LabResult(id);
	}
	
	public Patient getPatient(){
		return Patient.load(get(PATIENT_ID));
	}
	
	/**
	 * @deprecated use analysetime, observationtime and transmissiontime
	 */
	@Deprecated
	public String getDate(){
		return get(DATE);
	}
	
	@Override
	public void setDate(String value){
		set(DATE, value);
	}
	
	/**
	 * @deprecated use analysetime, observationtime and transmissiontime
	 */
	@Deprecated
	public TimeTool getDateTime(){
		String[] vals = get(false, TIME, DATE);
		return translateDateTime(vals[0], vals[1]);
	}
	
	/**
	 * @since 3.1
	 */
	private static TimeTool translateDateTime(String time, String date){
		if ((time == null) || ("".equals(time))) //$NON-NLS-1$
			time = "000000"; //$NON-NLS-1$
		while (time.length() < 6) {
			time += StringConstants.ZERO;
		}
		return new TimeTool(date + StringConstants.SPACE + time.substring(0, 2)
			+ StringConstants.COLON + time.substring(2, 4) + StringConstants.COLON
			+ time.substring(4, 6));
	}
	
	public ILabItem getItem(){
		return LabItem.load(get(ITEM_ID));
	}
	
	@Override
	public void setItem(ILabItem value){
		set(ITEM_ID, value.getId());
	}
	
	public String getResult(){
		if (getItem().getTyp() == LabItemTyp.FORMULA) {
			String value = null;
			// get the LabOrder for this LabResult
			List<LabOrder> orders =
				LabOrder.getLabOrders((String) null, (String) null, getItem(), this, null, null,
					null);
			if (orders != null && !orders.isEmpty()) {
				value = evaluteWithOrderContext(orders.get(0));
			}
			if (value == null || value.equals("?formel?")) { //$NON-NLS-1$
				TimeTool time = getTransmissionTime();
				if (time == null) {
					time = getDateTime();
				}
				value = evaluateWithDateContext(time);
			}
			setResult(value);
		}
		return checkNull(get(RESULT));
	}
	
	private String evaluteWithOrderContext(LabOrder order){
		String ret = null;
		try {
			ret = ((LabItem)getItem()).evaluate(getPatient(), order.getLabResults());
		} catch (ElexisException e) {
			ret = "?formel?"; //$NON-NLS-1$
		}
		return ret;
	}
	
	private String evaluateWithDateContext(TimeTool time){
		String ret = null;
		try {
			ret = ((LabItem)getItem()).evaluate(getPatient(), time);
		} catch (ElexisException e) {
			ret = "?formel?"; //$NON-NLS-1$
		}
		return ret;
	}
	
	public void setResult(final String res){
		int flags = isPathologic(getPatient().getGender(), getItem(), res) ? PATHOLOGIC : 0;
		set(new String[] {
			RESULT, FLAGS
		}, new String[] {
			checkNull(res), Integer.toString(flags)
		});
	}
	
	public String getComment(){
		return checkNull(get(COMMENT));
	}
	
	public void setComment(String comment) {
		set(COMMENT, comment);
	}
	
	public boolean isFlag(final int flag){
		return (getFlags() & flag) != 0;
	}
	
	public void setFlag(final int flag, final boolean set){
		int flags = getFlags();
		if (set) {
			flags |= flag;
		} else {
			flags &= ~(flag);
		}
		setInt(FLAGS, flags);
	}
	
	public int getFlags(){
		return checkZero(get(FLAGS));
	}
	
	@Override
	public void setFlags(int value){
		set(FLAGS, Integer.toString(value));
	}

	public String getUnit(){
		String ret = checkNull(get(UNIT));
		if (ret.isEmpty()) {
			ret = getItem().getUnit();
		}
		return ret;
	}
	
	public void setUnit(String unit){
		set(UNIT, unit);
	}
	
	/**
	 * Time the analyse was performed
	 * 
	 * @param time
	 */
	public TimeTool getAnalyseTime(){
		String timestr = checkNull(get(ANALYSETIME));
		if (timestr.isEmpty()) {
			return null;
		} else {
			return new TimeTool(timestr);
		}
	}
	
	/**
	 * Time the analyse was performed
	 * 
	 * @param time
	 */
	public void setAnalyseTime(TimeTool time){
		set(ANALYSETIME, time.toString(TimeTool.TIMESTAMP));
	}
	
	/**
	 * Time the specimen / sample was taken
	 * 
	 * @param time
	 */
	public TimeTool getObservationTime(){
		String timestr = checkNull(get(OBSERVATIONTIME));
		if (timestr.isEmpty()) {
			return null;
		} else {
			return new TimeTool(timestr);
		}
	}
	
	/**
	 * Time the specimen / sample was taken
	 * 
	 * @param time
	 */
	public void setObservationTime(TimeTool time){
		if (time != null) {
			set(OBSERVATIONTIME, time.toString(TimeTool.TIMESTAMP));
		}
	}
	
	/**
	 * Time the result was transmitted to Elexis.
	 * 
	 * @param time
	 */
	public TimeTool getTransmissionTime(){
		String timestr = checkNull(get(TRANSMISSIONTIME));
		if (timestr.isEmpty()) {
			return null;
		} else {
			return new TimeTool(timestr);
		}
	}
	
	/**
	 * Time the result was transmitted to Elexis.
	 * 
	 * @param time
	 */
	public void setTransmissionTime(TimeTool time){
		set(TRANSMISSIONTIME, time.toString(TimeTool.TIMESTAMP));
	}
	
	public String getRefMale(){
		return resolvePreferedRefValue(getItem().getReferenceMale(), REFMALE);
	}
	
	public void setRefMale(String value){
		set(REFMALE, value);
		setFlag(PATHOLOGIC, isPathologic(getPatient().getGender(), getItem(), getResult()));
	}
	
	public String getRefFemale(){
		return resolvePreferedRefValue(getItem().getReferenceFemale(), REFFEMALE);
	}
	
	public void setRefFemale(String value){
		set(REFFEMALE, value);
		setFlag(PATHOLOGIC, isPathologic(getPatient().getGender(), getItem(), getResult()));
	}
	
	/**
	 * get reference value based on user settings (either from local system (LabItem) or device sent
	 * (LabResult))
	 * 
	 * @param localRef
	 *            {@link LabItem} reference
	 * @param refField
	 *            male or female field of {@link LabResult}
	 * @return Preferred refValue. Per default reference of {@link LabItem} is returned
	 */
	private String resolvePreferedRefValue(String localRef, String refField){
		boolean useLocalRefs =
			CoreHub.userCfg.get(Preferences.LABSETTINGS_CFG_LOCAL_REFVALUES, true);
		
		if (useLocalRefs && localRef != null && !localRef.isEmpty()) {
			return localRef;
		} else {
			String ref = checkNull(get(refField));
			if (ref.isEmpty()) {
				log.info("using local LabRefVal [" + localRef
					+ "] as none could be resolved from labResult");
				return localRef;
			}
			return ref;
		}
	}
	
	/**
	 * Set arbitrary additional information
	 * 
	 * @param key
	 *            name of the information
	 * @param value
	 *            value of the information
	 */
	@SuppressWarnings("unchecked")
	public void setDetail(final String key, final String value){
		Map<Object, Object> ext = getMap(EXTINFO);
		if (value == null) {
			ext.remove(key);
		} else {
			ext.put(key, value);
		}
		setMap(EXTINFO, ext);
		
	}
	
	/**
	 * retrieve additional information
	 * 
	 * @param key
	 *            name of the requested information
	 * @return value if the information or null if no information with that name was found
	 */
	@SuppressWarnings("unchecked")
	public String getDetail(final String key){
		Map<Object, Object> ext = getMap(EXTINFO);
		return (String) ext.get(key);
	}
	
	@Override
	public String getLabel(){
		StringBuilder sb = new StringBuilder();
		sb.append(getItem().getLabel()).append(", ").append(getDate()).append(": ") //$NON-NLS-1$ //$NON-NLS-2$
			.append(getResult());
		return sb.toString();
		// return getResult();
	}
	
	public static LabResult getForDate(final Patient pat, final TimeTool date, final LabItem item){
		Query<LabResult> qbe = new Query<LabResult>(LabResult.class);
		qbe.add(ITEM_ID, Query.EQUALS, item.getId());
		qbe.add(PATIENT_ID, Query.EQUALS, pat.getId());
		qbe.add(DATE, Query.EQUALS, date.toString(TimeTool.DATE_COMPACT));
		List<LabResult> res = qbe.execute();
		if ((res != null) && (res.size() > 0)) {
			return res.get(0);
		}
		return null;
	}
	
	/**
	 * add a LabResult to the list of unseen LabResults. We do not keep LabResults older than
	 * KEEP_UNSEEN_LAB_RESULTS days in this list.
	 */
	public void addToUnseen(){
		List<LabResult> o = getUnseen();
		LinkedList<String> n = new LinkedList<String>();
		n.add(getId());
		TimeTool limit = new TimeTool();
		try { // We need to catch wrong formatted numbers in KEEP_UNSEEN
			limit.addHours(-24
				* Integer.parseInt(CoreHub.globalCfg.get(
					Preferences.LABSETTINGS_CFG_KEEP_UNSEEN_LAB_RESULTS,
					Preferences.DAYS_TO_KEEP_UNSEEN_LAB_RESULTS)));
		} catch (NumberFormatException nex) {
			ExHandler.handle(nex);
			limit.addHours(-24 * 7);
		}
		// log.log(limit.dump(),Log.INFOS);
		TimeTool tr = new TimeTool();
		for (LabResult lr : o) {
			//	log.info(lr.getDate());
			if (tr.set(lr.getDate())) {
				if (tr.isAfter(limit)) {
					n.add(lr.getId());
				}
			}
		}
		NamedBlob unseen = NamedBlob.load(LABRESULT_UNSEEN);
		String results = StringTool.join(n, ","); //$NON-NLS-1$
		unseen.putString(results);
		// unseen.set("lastupdate", new TimeTool().toString(TimeTool.TIMESTAMP));
	}
	
	/**
	 * Remove a lab result from the list of unseen results.
	 */
	public void removeFromUnseen(){
		NamedBlob unseen = NamedBlob.load(LABRESULT_UNSEEN);
		String results = unseen.getString();
		results = results.replaceAll(getId(), StringTool.leer);
		unseen.putString(results.replaceAll(",,", ",")); //$NON-NLS-1$ //$NON-NLS-2$
		// unseen.set("lastupdate", new TimeTool().toString(TimeTool.TIMESTAMP));
	}
	
	/**
	 * Return a List of unseen LabResults
	 * 
	 * @return
	 */
	public static List<LabResult> getUnseen(){
		LinkedList<LabResult> ret = new LinkedList<LabResult>();
		NamedBlob unseen = NamedBlob.load(LABRESULT_UNSEEN);
		String results = unseen.getString();
		if (results.length() > 0) {
			for (String id : results.split(",")) { //$NON-NLS-1$
				LabResult lr = load(id);
				if (lr.exists()) {
					ret.add(lr);
				}
			}
		}
		return ret;
	}
	
	/**
	 * return the time when the last change to the list of unseen results was made
	 * 
	 * @return a timestamp (as in System.CurrentTimeMillis())
	 */
	public static long getLastUpdateUnseen(){
		NamedBlob unseen = NamedBlob.load(LABRESULT_UNSEEN);
		long lastup = unseen.getLastUpdate();
		return lastup;
	}
	
	@Override
	public String toString(){
		return getLabel();
	}
	
	@Override
	public IContact getOriginContact(){
		Kontakt origin = getOrigin();
		if(origin==null) {
			return null;
		}
		return new ContactBean(origin);
	}

	@Override
	public void setOriginContact(IContact value){
		Kontakt load = Kontakt.load(value.getId());
		setOrigin(load);
	}

	public void setOrigin(Kontakt origin){
		if (origin != null && origin.exists()) {
			set(ORIGIN_ID, origin.getId());
		} else {
			set(ORIGIN_ID, ""); //$NON-NLS-1$
		}
	}
	
	public Kontakt getOrigin(){
		String id = get(ORIGIN_ID);
		if (id != null && !id.isEmpty()) {
			return Kontakt.load(id);
		}
		return null;
	}
	
	public static boolean isValidNumericRefValue(String value){
		List<String> refs = parseRefString(value);
		for (String string : refs) {
			try {
				if (string.trim().startsWith("<") || string.trim().startsWith(">")) { //$NON-NLS-1$ //$NON-NLS-2$
					Double.parseDouble(string.substring(1).trim());
				} else {
					String[] range = string.split("\\s*-\\s*"); //$NON-NLS-1$
					if (range.length == 2) {
						Double.parseDouble(range[0]);
						Double.parseDouble(range[1]);
					} else {
						return false;
					}
				}
			} catch (NumberFormatException nfe) {
				return false;
			}
		}
		return true;
	}
	
	public static boolean isValidAbsoluteRefValue(String value){
		for (String string : VALID_ABS_VALUES) {
			if (value.trim().equals(string)) {
				return true;
			}
		}
		return false;
	}
	
	/**
	 * LabResults grouped in HashMaps. 1st grouped by group, 2nd grouped by item, 3rd grouped by
	 * date containing a list of results.
	 * 
	 * @param pat
	 * @return
	 */
	public static HashMap<String, HashMap<String, HashMap<String, List<LabResult>>>> getGrouped(
		Patient pat){
		HashMap<String, HashMap<String, HashMap<String, List<LabResult>>>> ret =
			new HashMap<String, HashMap<String, HashMap<String, List<LabResult>>>>();
		if (pat == null) {
			return ret;
		}
		
		PreparedStatement ps =
			PersistentObject.getConnection().getPreparedStatement(QUERY_GROUP_ORDER);
		try {
			ps.setString(1, pat.getId());
			log.debug(ps.toString());
			ResultSet resi = ps.executeQuery();
			
			while ((resi != null) && (resi.next() == true)) {
				String val_id = resi.getString(1); // ID
				String val_ot = resi.getString(2); // Observationtime
				String val_date = resi.getString(3); // datum
				String val_time = resi.getString(4); // zeit
				String val_group = getNotNull(resi, 5); // grupppe
				String val_item = getNotNull(resi, 6); // kurzel
				
				HashMap<String, HashMap<String, List<LabResult>>> groupMap = ret.get(val_group);
				if (groupMap == null) {
					groupMap = new HashMap<String, HashMap<String, List<LabResult>>>();
					ret.put(val_group, groupMap);
				}
				
				HashMap<String, List<LabResult>> itemMap = groupMap.get(val_item);
				if (itemMap == null) {
					itemMap = new HashMap<String, List<LabResult>>();
					groupMap.put(val_item, itemMap);
				}
				
				TimeTool time = null;
				if (val_ot != null) {
					time = new TimeTool(val_ot);
				} else {
					time = translateDateTime(val_time, val_date);
				}
				
				String date = time.toString(TimeTool.DATE_COMPACT);
				List<LabResult> resultList = itemMap.get(date);
				if (resultList == null) {
					resultList = new ArrayList<LabResult>();
					itemMap.put(date, resultList);
				}
				
				resultList.add(new LabResult(val_id));
			}
		} catch (SQLException e) {
			log.error("Error in fetching labitem groups", e);
		} finally {
			PersistentObject.getConnection().releasePreparedStatement(ps);
		}
		
		return ret;
	}
	
	private static String getNotNull(ResultSet set, int index) throws SQLException{
		String ret = set.getString(index);
		if (ret == null) {
			ret = "";
		}
		return ret;
	}
	
	public static void changeObservationTime(Patient patient, TimeTool from, TimeTool to){
		Query<LabResult> qbe = new Query<LabResult>(LabResult.class);
		qbe.add(PATIENT_ID, Query.EQUALS, patient.getId());
		List<LabResult> res = qbe.execute();
		ArrayList<LabResult> changeList = new ArrayList<LabResult>();
		for (LabResult labResult : res) {
			TimeTool obsTime = labResult.getObservationTime();
			if (obsTime == null) {
				obsTime = labResult.getDateTime();
			}
			if (obsTime.isSameDay(from)) {
				changeList.add(labResult);
			}
		}
		for (LabResult labResult : changeList) {
			labResult.setObservationTime(to);
		}
	}

}
