Feature: Rollcall status screen
  In order to view general information about school surveillance data
  As a permitted user
  I should see status information when I browse to the Rollcall Home screen

  Background:
    Given the following entities exist:
      | Role         | SchoolNurse     |
      | Role         | Epidemiologist  |
      | Jurisdiction | Texas           |
      | Jurisdiction | Houston         |
    And Texas is the parent jurisdiction of:
      | Houston |
    And Houston has the following school districts:
      | Houston ISD |
    And "Houston ISD" has the following schools:
      | Name        | SchoolID | Level |
      | LEWIS ES    | 1        | ES    |
      | SOUTHMAYDES | 2        | ES    |
      | BERRY ES    | 3        | ES    |
    And the following users exist:
      | Nurse Betty  | nurse.betty@example.com | SchoolNurse    | Houston |
      | Nurse Betty  | nurse.betty@example.com | Rollcall       | Houston |
      | Epi Smith    | epi.smith@example.com   | Epidemiologist | Houston |
      | Epi Smith    | epi.smith@example.com   | Rollcall       | Houston |
    And "Houston ISD" has the following current absenteeism data:
      | Day   | SchoolName  | Enrolled | Absent |
      | 0     | LEWIS ES    | 500      | 5      |
      | -1    | LEWIS ES    | 500      | 10     |
      | -2    | LEWIS ES    | 500      | 15     |
      | -3    | LEWIS ES    | 500      | 5      |
      | -4    | LEWIS ES    | 500      | 60     |
      | 0     | SOUTHMAYDES | 100      | 2      |
      | -1    | SOUTHMAYDES | 100      | 5      |
      | -2    | SOUTHMAYDES | 100      | 15     |
      | -3    | SOUTHMAYDES | 100      | 10     |
      | -4    | SOUTHMAYDES | 100      | 7      |
      | 0     | BERRY ES    | 200      | 10     |
      | -1    | BERRY ES    | 200      | 15     |
      | -2    | BERRY ES    | 200      | 5      |
      | -3    | BERRY ES    | 200      | 10     |
      | -4    | BERRY ES    | 200      | 10     |

Scenario: Accessing the Rollcall application
  Given I am logged in as "nurse.betty@example.com"
  When I go to the dashboard page
  Then I should see the following menu:
    | name | portal_toolbar |
    | item | Rollcall       |
  
Scenario: Viewing the Home screen
  Given I am logged in as "nurse.betty@example.com"
  When I go to the rollcall page
  Then I should see the following menu:
			| name | app_toolbar |
			| item | Main        |
      | item | School View |

Scenario: Seeing the average absenteeism graph(s)
  Given I am logged in as "nurse.betty@example.com"
  When I go to the rollcall page
  Then I should see an absenteeism graph with the following:
    | data        | 0,0,8.0,5.33,6.83,4.83,2.67 |
    | data-label  | Houston ISD                  |
    | title       | Average % Absenteeism        |
    | range       | 0,30                         |

Scenario: Seeing the abseentism alert summary
  Given I am logged in as "nurse.betty@example.com"
  When I go to the rollcall page
  Then I should see an "low" rollcall summary for "LEWIS ES" with 12.0% absenteeism
  Then I should see an "medium" rollcall summary for "SOUTHMAYDES" with 15.0% absenteeism
  And I should not see a rollcall alert for "BERRY ES"

Scenario: Changing the timespan of the absenteeism graph
  Given I am logged in as "nurse.betty@example.com"
  When I go to the rollcall page
  And I select "90" from "Show last"
  And I press "Modify graph"
  Then I should see an absenteeism graph with the following:
    | data        | 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8.0,5.33,6.83,4.83,2.67 |