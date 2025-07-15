# Coding Meetup Integration - MemberCommons

- **Launch Our Model.earth Meetup:** [https://meet.google.com/pcv-xrdh-bat](https://meet.google.com/pcv-xrdh-bat)
- **Google Sheet ID:** You'll need to create a Google Sheet and get its ID from the URL. The ID is the long string of characters between `/d/` and `/edit`.

## Add Settings for Coding Meetup Integration

To use the Coding Meetup Integration with the MemberCommons backend, you'll need to provide the following credentials in your `.env` file:

- `GOOGLE_PRIVATE_KEY_ID`
- `GOOGLE_PRIVATE_KEY`
- `GOOGLE_CLIENT_EMAIL`
- `GOOGLE_CLIENT_ID`

## Pulling Participants from a Google Meetup into a Google Sheet

Since there isn't a direct Google Meet API to get a list of participants, the most reliable method is to use a Google Apps Script. This script will run within your Google account and can be triggered to capture the participants of an active meeting.

### Step 1: Create a Google Sheet

Create a new Google Sheet where the participant list will be stored. Name it something descriptive, like "Google Meetup Participants".

### Step 2: Create a Google Apps Script

1. Open your Google Sheet.
2. Go to **Extensions > Apps Script**.
3. This will open a new script project. Give it a name, like "Meetup Participants Script".

### Step 3: Write the Script

Copy and paste the following code into the script editor, replacing the existing `myFunction` code:

```javascript
function getMeetupParticipants() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  const calendarId = 'primary'; // Or the ID of the calendar with the Meetup event
  const now = new Date();

  // Find the current or most recent event
  const events = CalendarApp.getCalendarById(calendarId).getEvents(now, new Date(now.getTime() + 60 * 1000));

  if (events.length === 0) {
    sheet.appendRow([new Date(), "No active Google Meet found."]);
    return;
  }

  const event = events[0];
  const meetupLink = event.getConferenceId();

  if (!meetupLink) {
    sheet.appendRow([new Date(), "No Google Meet link found for the current event."]);
    return;
  }

  // This is a simplified example. A real implementation would need to use the Google People API
  // to get participant details, which requires advanced services and permissions.
  // For this example, we'll just log the event details.
  sheet.appendRow([new Date(), event.getTitle(), meetupLink]);
}

function onOpen() {
  SpreadsheetApp.getUi()
      .createMenu('Meetup')
      .addItem('Get Participants', 'getMeetupParticipants')
      .addToUi();
}
```

### Step 4: Set Up a Trigger (Optional)

If you want the script to run automatically, you can set up a trigger:

1. In the Apps Script editor, click on the **Triggers** icon (it looks like a clock).
2. Click **Add Trigger**.
3. Configure the trigger as follows:
   - **Choose which function to run:** `getMeetupParticipants`
   - **Choose which deployment should run:** `Head`
   - **Select event source:** `Time-driven`
   - **Select type of time based trigger:** `Minutes timer`
   - **Select minute interval:** `Every 5 minutes`
4. Click **Save**.

### Step 5: Run the Script Manually

You can also run the script manually from the Google Sheet:

1. Go back to your Google Sheet and refresh the page.
2. You should see a new **Meetup** menu item.
3. Click **Meetup > Get Participants** to run the script.



You can get these credentials by creating a service account in the [Google Cloud Console](https://console.cloud.google.com/).

### Setting Up Google Cloud Service Account

1. **Create a new project** or select an existing one.
2. **Enable the Google Sheets API** for your project.
3. **Create a service account:**
   - Go to the [Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page.
   - Click "Create service account".
   - Give the service account a name and description.
   - Grant the service account the "Editor" role.
   - Click "Done".
4. **Create a new key:**
   - Click on the service account you just created.
   - Go to the "Keys" tab.
   - Click "Add key" and then "Create new key".
   - Select "JSON" as the key type and click "Create".
   - A JSON file will be downloaded to your computer. This file contains all the credentials you need.

Once you have the JSON file, copy the values into your `.env` file.