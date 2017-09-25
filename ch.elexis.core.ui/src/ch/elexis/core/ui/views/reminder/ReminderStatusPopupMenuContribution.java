package ch.elexis.core.ui.views.reminder;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.swt.SWT;

import ch.elexis.core.model.issue.ProcessStatus;
import ch.elexis.core.ui.util.viewers.CommonViewer;
import ch.elexis.data.Reminder;

public class ReminderStatusPopupMenuContribution implements IMenuListener {
	
	private CommonViewer cv;
	
	public ReminderStatusPopupMenuContribution(CommonViewer cv){
		this.cv = cv;
	}
	
	@Override
	public void menuAboutToShow(IMenuManager manager){
		Object[] selection = cv.getSelection();
		if (selection != null && selection.length == 1) {
			Reminder reminder = (Reminder) selection[0];
			manager.add(new StatusAction(ProcessStatus.OPEN, reminder));
			manager.add(new StatusAction(ProcessStatus.IN_PROGRESS, reminder));
			manager.add(new StatusAction(ProcessStatus.CLOSED, reminder));
		} else {
			manager.add(new Action("WRONG") {
				@Override
				public boolean isEnabled(){
					return false;
				}
			});
		}
	}
	
	private class StatusAction extends Action {

		private final ProcessStatus representedStatus;
		private Reminder reminder;
		
		public StatusAction(ProcessStatus representedStatus, Reminder reminder){
			super(representedStatus.getLocaleText(), SWT.RADIO);
			this.representedStatus = representedStatus;
			this.reminder = reminder;
		}

		@Override
		public boolean isChecked(){
			return (representedStatus == reminder.getStatus());
		}
		
		@Override
		public void setChecked(boolean checked){
			// TODO LOCK!!
			reminder.setStatus(representedStatus);
			super.setChecked(checked);
		}
	}
}
