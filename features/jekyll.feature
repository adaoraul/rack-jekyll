Feature: Rack-Jekyll
  In order to ensure results are correct
  As a Jekyll
  I want to become a Rack application

  Scenario: Request info
    Given I haven entered the path /
    When I request a page
    Then the http status should be 200
    Then the content-type should be text/html
