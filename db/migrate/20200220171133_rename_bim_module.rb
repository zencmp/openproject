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

class RenameBimModule < ActiveRecord::Migration[6.0]
  def up
    projects_with_bcf = EnabledModule.where(name: 'bcf').pluck(:project_id)
    # Delete all bcf to avoid duplicates
    EnabledModule.where(name: 'bcf').delete_all
    EnabledModule.where(name: 'ifc_models').update_all(name: 'bim')

    # Re-enable bim if ifc_models was not active but bcf was
    Project.where(id: projects_with_bcf).includes(:enabled_modules).each do |project|
      project.enabled_modules.create(name: 'bim') unless project.enabled_module_names.include?('bim')
    end

    # Rename attachments container
    Attachment.where(container_type: 'Bcf::Viewpoint').update_all(container_type: 'Bim::Bcf::Viewpoint')
    Attachment.where(container_type: 'IFCModels::IFCModel').update_all(container_type: 'Bim::IfcModels::IfcModel')
  end

  def down
    # We cannot now which module was active, so enable BCF
    EnabledModule.where(name: 'bim').update_all(name: 'bcf')

    # Rename attachments container
    Attachment.where(container_type: 'Bim::Bcf::Viewpoint').update_all(container_type: 'Bcf::Viewpoint')
    Attachment.where(container_type: 'Bim::IfcModel::IfcModel').update_all(container_type: 'IFCModels::IFCModel')
  end
end
