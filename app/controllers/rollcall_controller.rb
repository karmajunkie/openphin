=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end

class RollcallController < ApplicationController
  app_toolbar "rollcall"

  def index
    @districts = current_user.jurisdictions.map(&:school_districts).flatten!

    reports = current_user.recent_absentee_reports
    reports_schools = reports.map(&:school).flatten.uniq
    reports_districts = reports_schools.map(&:district).flatten.uniq
    @statistics = {}
    reports_districts.each do |district|
      @statistics[district.name] = {} unless @statistics[district.name]
      reports_schools.each do |school|
        if school.district == district
          @statistics[district.name][school.display_name] = [] unless @statistics[district.name][school.display_name]
          reports.each do |report|
            if report.school == school
              @statistics[district.name][school.display_name] << report
            end
          end
        end
      end
    end
  end
end