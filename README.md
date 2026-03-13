# Product Requirement Document (PRD)
## Smart Class Check-in & Learning Reflection App

## 1. Problem Statement
Universities need a simple and reliable way to confirm student attendance and participation in class sessions. Traditional attendance methods do not verify physical presence or student engagement. This product provides a mobile workflow where students check in before class and complete a reflection after class using GPS, QR code validation, and short learning inputs.

## 2. Target Users
- Primary users: University students attending in-person classes
- Secondary users: Instructors/admins reviewing attendance and reflection records

## 3. Product Goals
- Verify student physical presence during class start and class end
- Capture simple evidence of participation through learning reflections
- Provide a fast, low-friction process that can be completed within 1–2 minutes

## 4. Scope (MVP)
### In Scope
- Flutter mobile app with 3 screens:
  - Home Screen
  - Check-in Screen (Before Class)
  - Finish Class Screen (After Class)
- GPS location capture at check-in and finish class
- QR code scan at check-in and finish class
- Form submission for required text/mood fields
- Local data storage (SQLite or local storage)
- Basic input validation (required fields)

### Out of Scope (MVP)
- Advanced analytics dashboard
- Multi-role access control
- Push notifications
- Offline sync conflict handling

## 5. Features
### 5.1 Home Screen
- Buttons to navigate to:
  - Check-in
  - Finish Class
- Optional: List of latest local submissions

### 5.2 Check-in (Before Class)
Student actions:
1. Tap **Check-in**
2. Capture GPS location and timestamp
3. Scan class QR code
4. Fill form fields:
   - Previous class topic
   - Expected topic for today
   - Mood before class (1–5)
5. Submit and save record

### 5.3 Finish Class (After Class)
Student actions:
1. Tap **Finish Class**
2. Scan class QR code again
3. Capture GPS location and timestamp
4. Fill form fields:
   - What I learned today
   - Feedback about class/instructor
5. Submit and save record

## 6. User Flow
1. Student opens app on Home Screen
2. Before class: completes Check-in flow
3. System validates required fields and saves record
4. After class: completes Finish Class flow
5. System validates required fields and saves record
6. Student sees success message after each submission

## 6.1 System Workflow Summary (Validation Points)
1. User selects action from Home (`Check-in` or `Finish Class`)
2. App requests required permission(s): location and camera
3. User scans QR code (must succeed before submit)
4. App captures GPS coordinates and current timestamp
5. User completes required form fields
6. App validates all required fields:
  - QR value is not empty
  - GPS coordinates exist
  - Required text fields are filled
  - Mood is within 1–5 (for Check-in)
7. App stores record locally
8. App displays success or failure feedback

## 7. Functional Requirements
- App must request and use location permission before GPS capture
- App must open camera and scan QR code
- Check-in and Finish Class forms must enforce required fields
- Mood must be integer value from 1 to 5
- Each submission must be stored locally with timestamp
- App should show error message on scan/location/input failure

## 8. Data Model (MVP)
### 8.1 Check-in Record
- id (string/uuid)
- studentId (string, optional for MVP)
- qrCodeValue (string)
- latitude (double)
- longitude (double)
- checkInTimestamp (datetime)
- previousClassTopic (string)
- expectedTodayTopic (string)
- moodBeforeClass (int: 1–5)
- createdAt (datetime)

### 8.2 Finish Class Record
- id (string/uuid)
- studentId (string, optional for MVP)
- qrCodeValue (string)
- latitude (double)
- longitude (double)
- finishTimestamp (datetime)
- learnedToday (string)
- feedback (string)
- createdAt (datetime)

## 8.3 Data Relationships (MVP)
- One student can create multiple `Check-in` records (across class sessions/dates)
- One student can create multiple `Finish Class` records (across class sessions/dates)
- For reporting, records can be grouped by `studentId + date/session`
- Check-in and Finish records are logically paired by same student and same class session time window

## 9. Non-Functional Requirements
- Usability: Submission flow should complete in under 2 minutes
- Reliability: App should not crash on denied permission; show clear fallback messages
- Performance: Form submission and local save under 2 seconds on typical device
- Maintainability: Clear folder structure and readable code

## 10. Tech Stack
- Frontend: Flutter (Dart)
- QR scanning: `mobile_scanner` (or equivalent)
- GPS: `geolocator` + `geocoding` (optional)
- Local database: `sqflite` (or `shared_preferences` for minimal MVP)
- Backend/hosting (deployment requirement): Firebase Hosting (Flutter Web build or demo page)
- Version control: Git + GitHub

## 11. Acceptance Criteria (MVP)
- User can complete Check-in with GPS + QR + required form fields
- User can complete Finish Class with GPS + QR + required form fields
- Both records are stored locally and retrievable in app logs/list
- At least one component is deployed and accessible via Firebase URL
- README includes setup, run steps, and Firebase notes

## 12. Risks and Mitigation
- Permission denied (GPS/camera): show guidance and retry option
- QR scan failure: allow rescan immediately
- Device GPS delay: show loading indicator and timeout message
- Time limitation in exam: prioritize core flow and local save first, then deployment

---
Prepared for: Midterm Lab Exam (Mobile Application Development)
Date: 13-Mar-2026
