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

class AddColumnConversionStatusToIfcModel < ActiveRecord::Migration[6.1]
  def up
    add_column(:ifc_models, :conversion_status, :integer, default: 0) # default "pending"
    add_column(:ifc_models, :conversion_error_message, :text)

    converted_models = ::Bim::IfcModels::IfcModel
                         .joins(:attachments)
                         .where("attachments.description = 'xkt'")

    not_converted_models = ::Bim::IfcModels::IfcModel
                             .where
                             .not(id: converted_models)

    converted_models.update_all(conversion_status: 2) # 2 == processed
    not_converted_models.update_all(conversion_status: 3) # 3 == error
  end

  def down
    remove_column(:ifc_models, :conversion_status)
    remove_column(:ifc_models, :conversion_error_message)
  end
end
