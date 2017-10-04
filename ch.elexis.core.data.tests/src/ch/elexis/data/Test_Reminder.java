package ch.elexis.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.junit.Test;

import ch.elexis.core.constants.StringConstants;
import ch.elexis.core.data.activator.CoreHub;
import ch.elexis.core.data.events.ElexisEvent;
import ch.elexis.core.data.events.ElexisEventDispatcher;
import ch.elexis.core.model.issue.ProcessStatus;
import ch.elexis.core.model.issue.Visibility;
import ch.rgw.tools.JdbcLink;
import ch.rgw.tools.TimeTool;

public class Test_Reminder extends AbstractPersistentObjectTest {
	
	private Anwender anwender;
	private Patient patient;
	
	public Test_Reminder(JdbcLink link){
		super(link);
		
		User user = User.load("Administrator");
		if (user.getAssignedContact() == null) {
			anwender = new Anwender("Name", "Vorname", (String) null, "w");
			user.setAssignedContact(anwender);
		} else {
			anwender = user.getAssignedContact();
		}
		// set user and Mandant in system
		ElexisEventDispatcher.getInstance()
			.fire(new ElexisEvent(user, User.class, ElexisEvent.EVENT_SELECTED));
		Mandant m = new Mandant("Mandant", "Erwin", "26.07.1979", "m");
		patient = new Patient("Mia", "Krank", "22041982", "w");
		CoreHub.setMandant(m);
	}
	
	@Test
	public void testSetResponsibleUser() throws InterruptedException{
		Reminder reminder = new Reminder(null, new TimeTool().toString(TimeTool.DATE_GER),
			Visibility.ALWAYS, "", "TestMessage");
		long lastUpdate = reminder.getLastUpdate();
		assertNotSame(0L, reminder.getLastUpdate());
		Thread.sleep(2);
		reminder.setResponsible(Collections.singletonList(anwender));
		assertTrue(reminder.getLastUpdate() > lastUpdate);
		assertEquals(1, reminder.getResponsibles().size());
		assertEquals(StringConstants.EMPTY, reminder.get(Reminder.FLD_RESPONSIBLE));
		lastUpdate = reminder.getLastUpdate();
		Thread.sleep(2);
		reminder.setResponsible(new ArrayList<Anwender>());
		assertTrue(reminder.getLastUpdate() > lastUpdate);
		assertEquals(0, reminder.getResponsibles().size());
		assertEquals(StringConstants.EMPTY, reminder.get(Reminder.FLD_RESPONSIBLE));
		reminder.setResponsible(null);
		assertTrue(reminder.getLastUpdate() > lastUpdate);
		assertNull(reminder.getResponsibles());
		assertEquals(Reminder.ALL_RESPONSIBLE, reminder.get(Reminder.FLD_RESPONSIBLE));
		reminder.delete();
	}
	
	@Test
	public void testFindOpenRemindersResponsibleFor(){
		Reminder reminderClosed = new Reminder(null, new TimeTool().toString(TimeTool.DATE_GER),
			Visibility.ALWAYS, "", "TestMessage");
		reminderClosed.setResponsible(Collections.singletonList(CoreHub.actUser));
		reminderClosed.set(Reminder.FLD_STATUS,
			Integer.toString(ProcessStatus.CLOSED.numericValue()));
		
		Reminder reminder = new Reminder(null, new TimeTool().toString(TimeTool.DATE_GER),
			Visibility.ALWAYS, "", "TestMessage");
		reminder.setResponsible(Collections.singletonList(CoreHub.actUser));
		List<Reminder> findOpenRemindersResponsibleFor = Reminder.findOpenRemindersResponsibleFor(CoreHub.actUser, false, null, false);
		assertEquals(1,
			findOpenRemindersResponsibleFor.size());
		
		Reminder patientSpecificReminder = new Reminder(patient,
			new TimeTool().toString(TimeTool.DATE_GER), Visibility.ALWAYS, "", "TestMessage");
		patientSpecificReminder.setResponsible(null);
		assertEquals(2,
			Reminder.findOpenRemindersResponsibleFor(CoreHub.actUser, false, null, false).size());
		assertEquals(1,
			Reminder.findOpenRemindersResponsibleFor(null, false, patient, false).size());
		
		Reminder popupReminder = new Reminder(patient, new TimeTool().toString(TimeTool.DATE_GER),
			Visibility.POPUP_ON_PATIENT_SELECTION, "", "TestMessage");
		popupReminder.setResponsible(Collections.singletonList(CoreHub.actUser));
		assertEquals(3,
			Reminder.findOpenRemindersResponsibleFor(CoreHub.actUser, false, null, false).size());
		assertEquals(1,
			Reminder.findOpenRemindersResponsibleFor(CoreHub.actUser, false, null, true).size());
		assertEquals(1,
			Reminder.findOpenRemindersResponsibleFor(CoreHub.actUser, false, patient, true).size());
		
		TimeTool timeTool = new TimeTool(LocalDate.now().minusDays(1));
		Reminder dueReminder = new Reminder(null, timeTool.toString(TimeTool.DATE_GER),
			Visibility.ALWAYS, "", "TestMessage");
		dueReminder.setResponsible(Collections.singletonList(anwender));
		// is 120217
		List<Reminder> dueReminders =
			Reminder.findOpenRemindersResponsibleFor(anwender, true, null, false);
		assertEquals(2, dueReminders.size());
		
		dueReminder.delete();
		reminderClosed.delete();
		reminder.delete();
		patientSpecificReminder.delete();
		popupReminder.delete();
	}
	
	@Test
	public void testFindAllUserIsResponsibleFor(){
		Reminder reminderClosed = new Reminder(null, new TimeTool().toString(TimeTool.DATE_GER),
			Visibility.ALWAYS, "", "TestMessage");
		reminderClosed.setResponsible(Collections.singletonList(CoreHub.actUser));
		reminderClosed.set(Reminder.FLD_STATUS,
			Integer.toString(ProcessStatus.CLOSED.numericValue()));
		
		Reminder reminder = new Reminder(null, new TimeTool().toString(TimeTool.DATE_GER),
			Visibility.ALWAYS, "", "TestMessage");
		reminder.setResponsible(Collections.singletonList(CoreHub.actUser));
		
		Reminder reminderAll = new Reminder(null, new TimeTool().toString(TimeTool.DATE_GER),
			Visibility.ALWAYS, "", "TestMessage");
		reminderAll.setResponsible(null);
		
		assertEquals(3, Reminder.findAllUserIsResponsibleFor(CoreHub.actUser, false).size());
		
		reminderClosed.delete();
		reminder.delete();
		reminderAll.delete();
	}
	
}
