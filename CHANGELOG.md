## 0.10.3 - November 17, 2025
* Bug Fix: Querying appUsageData with previous dates returns a type error of converting long to int. Switched appUsageData to take in a Number rather than int for start/end milliseconds.
* Bug Fix: Querying appUsageData with previous dates that have no screen time will return the data from the most recent previous date that has data rather than returning zero. Now, instead of returning all data (previous non-zero day if zero), filter down query results to those specific to that date.

## 0.10.2 - May 1, 2025
* Handle same action when request permission app usage, accessibility settings, and draw overlay to request family controls
* Handle same action when check permission app usage, accessibility settings, and draw overlay to check family controls

## 0.10.1 - May 1, 2025
* Fix Request Permission notification for iOS
* Fix Permission Status notification for iOS

## 0.10.0 - May 1, 2025
* Request Permission for iOS
* Permission Status for iOS

## 0.9.1 - April 24, 2025
* Fix Pause Blocking App response from map to boolean
* Add checker is on paused blocking or not
* Fix Cancel All Paused Blocking App when unblock

## 0.9.0 - April 22, 2025
* Implement Pause Blocking App
* Handle auto resume after paused
* Improve handle overlay

## 0.8.0 - April 18, 2025
* Configurable overlay UI
* Configurable notification title
* Configurable notificaiton text
* Fix draw overlay lifecycle
* Fix block app service lifecycle

## 0.7.2 - April 14, 2025
* Add request permission notification required for Android > 13
* Add check permission notification
* Remove query all packages permission
* Remove check permission query all packages

## 0.7.1 - April 14, 2025
* Fix usage time in duration

## 0.7.0 - April 14, 2025
* Block Specific Apps
* Unblock Specific Apps
* Check block is on going or not

## 0.6.1 - April 11, 2025
* Add checker for is on blocking apps or not
* Stop service on unblock

## 0.6.0 - April 11, 2025
* Implement Blocked Apps

## 0.5.0 - April 10, 2025
* Add request permission draw overlay
* Add check permission draw overlay

## 0.4.2 - April 6, 2025
* Add App Category on App Usage
* To get category better to use minimum Android 26

## 0.4.1 - April 6, 2025
* Improvement fetch app installed on android 13

## 0.4.0 - April 3, 2025
* Centralized Request Permission
* Centralized Permission Status

## 0.3.0 - April 3, 2025
* Android, Filter installed by user only
* App Usage, retrieve based on specific package name

## 0.2.0 - April 2, 2025
* Android, retrieve app usage time using UsageStatsManager
* Android, check permission for usage stats using AppOpsManager
* Android, implement Accessibility Service for real-time monitoring

## 0.1.0 - April 2, 2025
* Android, Fetch Installed App
* Android, Fetch Installed App by Category