@alert
Feature: Canceling an alert

  In order to keep everyone informed with up to date information
  As an alerter
  I want to be able to send out a cancel alert

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County   |
      | Role         | Health Officer  |
      | Role         | HAN Coordinator |
    And the following users exist:
      | John Smith      | john.smith@example.com     | HAN Coordinator  | Dallas County  |
      | Brian Simms     | brian.simms@example.com    | Health Officer  | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com    | Health Officer  | Dallas County  |
      
    And the role "HAN Coordinator" is an alerter

  Scenario: Canceling an alert
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I've sent an alert with:
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
      | Title         | Flying Monkey Disease                |
      | Message       | For more details, keep on reading... |
      | Severity      | Moderate            |
      | Status        | Actual              |
      | Acknowledge   | <unchecked>         |
      | Communication methods | E-mail      |
      | Delivery Time | 60 minutes          |
      
    When I go to cancel the alert
    And I make changes to the alert form with:
      | Message    | Flying monkey disease is not contagious |
    And I press "Preview Message"

    Then I should see a preview of the message with:
      | Jurisdictions | Dallas County  |
      | Roles | Health Officer         |
      | Title    | [Cancel] - Flying Monkey Disease        |
      | Message  | Flying monkey disease is not contagious |
      | Severity | Moderate            |
      | Status   | Actual              |
      | Acknowledge | No               |
      | Communication methods | E-mail |
      | Delivery Time | 60 minutes     |
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the logs page
    And the following users should receive the email:
      | People        | brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | Moderate Health Alert from Dallas County : John Smith : HAN Coordinator |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: [Cancel] - Flying Monkey Disease |
      | body contains | Flying monkey disease is not contagious |
    
    
