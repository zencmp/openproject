#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++
module BasicData
  class StatusSeeder < Seeder
    def seed_data!
      Status.transaction do
        data.each do |attributes|
          reference = attributes.delete(:reference)
          status = Status.create!(attributes)
          seed_data.store_reference(reference, status)
        end
      end
    end

    def applicable
      Status.all.any?
    end

    def not_applicable_message
      'Skipping statuses - already exists/configured'
    end

    def data
      Array(seed_data.lookup('statuses')).map do |status_data|
        {
          reference: status_data['reference'],
          name: status_data['name'],
          color_id: color_id(status_data['color_name']),
          is_closed: true?(status_data['is_closed']),
          is_default: true?(status_data['is_default']),
          position: status_data['position']
        }
      end
    end

    protected

    def color_id(name)
      @color_ids_by_name ||= Color.pluck(:name, :id).to_h
      @color_ids_by_name[name] or raise "Cannot find color #{name}"
    end
  end
end
