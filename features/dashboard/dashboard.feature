Feature: Viewing the dashboard

    Background:
        Given the following entities exists:
          | Jurisdiction | Dallas County         |
          | Jurisdiction | Tarrant County        |
          | Jurisdiction | Texas                 |
          | Role         | Public                |
          | Role         | Health Officer        |
          | Role         | Immunization Director |
          | Role         | HAN Coordinator       |
        And Texas is the parent jurisdiction of:
          | Dallas County | Tarrant County |
        And Dallas County has the following administrators:
          | Bob Jones      | admin1@dallascounty.com      |
          | Quincy Jones   | admin2@dallascounty.com   |
        And Tarrant County has the following administrators:
          | TarrantCounty Admin  | admin@tarrantcounty.com      |
        And Texas has the following administrators:
          | Zach Dennis   | admin@texas.com      |

    Scenario: Dashboard should show the unapproved role requests
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And I am logged in as "john.smith@example.com"
    And "john.smith@example.com" has requested to be a "HAN Coordinator" for "Dallas County"
    When I go to the dashboard page
    Then I should see 1 pending role request

    Scenario: Dashboard should show the most recent approved role requests
    Given the following users exist:
          | John Smith      | john.smith@example.com   | Public | Dallas County |
    And "admin1@texas.com" has approved the "Health Officer" role in "Dallas County" for "john.smith@example.com" 2 days ago
    And I am logged in as "john.smith@example.com"
    And "john.smith@example.com" has requested to be a "HAN Coordinator" for "Dallas County"
    And "admin1@dallascounty.com" has approved the "HAN Coordinator" role in "Dallas County" for "john.smith@example.com"
    When I go to the dashboard page
    Then I should see 1 recent role approval


    Scenario: Dashboard should show only the panels each user has access to
