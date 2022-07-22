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

# require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'spec_helper'

describe SecureContextUriValidator do
  subject do
    Class.new do
      include ActiveModel::Validations
      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      attr_accessor :host

      validates :host, secure_context_uri: true
    end.new
  end

  context 'with empty URI' do
    ['', ' ', nil].each do |uri|
      describe "when URI is '#{uri}'" do
        it "adds an 'could_not_parse' error" do
          subject.host = uri
          subject.validate
          expect(subject.errors).to include(:host)
        end
      end
    end
  end

  context 'with invalid URI' do
    %w(nope httppp://192.168.0.1 http://192.168 http://<>ample.com).each do |uri|
      describe "when URI is '#{uri}'" do
        it "adds an error" do
          subject.host = uri
          subject.validate
          expect(subject.errors).to include(:host)
        end
      end
    end
  end

  context 'with secure URI' do
    %w(https://example.com http://localhost http://.localhost http://foo.localhost. http://foo.localhost).each do |uri|
      describe "when URI is '#{uri}'" do
        it "does not add an error" do
          subject.host = uri
          subject.validate
          expect(subject.errors).not_to include(:host)
        end
      end
    end
  end

  context 'with secure IPV6 URI' do
    %w(http://[::1]).each do |uri|
      describe "when URI is '#{uri}'" do
        it "does not add an error" do
          subject.host = uri
          subject.validate
          expect(subject.errors).not_to include(:host)
        end
      end
    end
  end
end
