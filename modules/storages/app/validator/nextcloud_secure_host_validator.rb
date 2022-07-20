#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
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
class NextcloudSecureHostValidator < ActiveModel::EachValidator
  # A "secure" Nextcloud host is either a host via https or
  # localhost/127.0.0.1. Ports are ignored.
  def validate_each(contract, attribute, value)
    begin
      uri = URI.parse(value)
    rescue StandardError
      contract.errors.add(attribute, :could_not_parse_host_uri)
      return
    end

    return if uri.scheme == 'https' # https is always safe
    return if ['localhost', '127.0.0.1'].include?(uri.host) # localhost is always safe

    contract.errors.add(attribute, :host_not_https_or_localhost)
  end
end
