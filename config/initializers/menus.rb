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

require 'redmine/menu_manager'

Redmine::MenuManager.map :top_menu do |menu|
  # projects menu will be added by
  # Redmine::MenuManager::TopMenuHelper#render_projects_top_menu_node
  menu.push :projects,
            { controller: '/projects', project_id: nil, action: 'index' },
            context: :modules,
            caption: I18n.t('label_projects_menu'),
            if: Proc.new {
              (User.current.logged? || !Setting.login_required?)
            }
  menu.push :work_packages,
            { controller: '/work_packages', project_id: nil, state: nil, action: 'index' },
            context: :modules,
            caption: I18n.t('label_work_package_plural'),
            if: Proc.new {
              (User.current.logged? || !Setting.login_required?) &&
                User.current.allowed_to_globally?(:view_work_packages)
            }
  menu.push :news,
            { controller: '/news', project_id: nil, action: 'index' },
            context: :modules,
            caption: I18n.t('label_news_plural'),
            if: Proc.new {
              (User.current.logged? || !Setting.login_required?) &&
                User.current.allowed_to_globally?(:view_news)
            }

  if OpenProject::FeatureDecisions.more_global_index_pages_active?
    menu.push :meetings,
              { controller: '/meetings', project_id: nil, action: 'index' },
              context: :modules,
              caption: I18n.t('label_meetings_plural'),
              if: Proc.new {
                (User.current.logged? || !Setting.login_required?) &&
                  User.current.allowed_to_globally?(:view_meetings)
              }
  end

  menu.push :help,
            OpenProject::Static::Links.help_link,
            last: true,
            caption: '',
            icon: 'help',
            html: { accesskey: OpenProject::AccessKeys.key_for(:help),
                    title: I18n.t('label_help'),
                    target: '_blank' }
end

Redmine::MenuManager.map :quick_add_menu do |menu|
  menu.push :new_project,
            Proc.new { |project|
              { controller: '/projects', action: :new, project_id: nil, parent_id: project&.id }
            },
            caption: ->(*) { Project.model_name.human },
            icon: "add",
            html: {
              aria: { label: I18n.t(:label_project_new) },
              title: I18n.t(:label_project_new)
            },
            if: ->(project) {
              User.current.allowed_to_globally?(:add_project) ||
                User.current.allowed_to?(:add_subprojects, project)
            }

  menu.push :invite_user,
            nil,
            caption: :label_invite_user,
            icon: 'user-plus',
            html: {
              'invite-user-modal-augment': 'invite-user-modal-augment'
            },
            if: Proc.new { User.current.allowed_to_globally?(:manage_members) }
end

Redmine::MenuManager.map :account_menu do |menu|
  menu.push :my_page,
            :my_page_path,
            caption: I18n.t('js.my_page.label'),
            if: Proc.new { User.current.logged? }
  menu.push :my_account,
            { controller: '/my', action: 'account' },
            if: Proc.new { User.current.logged? }
  menu.push :administration,
            { controller: '/admin', action: 'index' },
            if: Proc.new {
              User.current.allowed_to_globally?(:create_backup) ||
                User.current.allowed_to_globally?(:manage_placeholder_user) ||
                User.current.allowed_to_globally?(:manage_user)
            }
  menu.push :logout,
            :signout_path,
            if: Proc.new { User.current.logged? }
end

Redmine::MenuManager.map :application_menu do |menu|
  menu.push :work_packages_query_select,
            { controller: '/work_packages', action: 'index' },
            parent: :work_packages,
            partial: 'work_packages/menu_query_select',
            last: true
end

Redmine::MenuManager.map :notifications_menu do |menu|
  menu.push :notification_grouping_select,
            { controller: '/my', action: 'notifications' },
            partial: 'notifications/menu_notification_center'
end

Redmine::MenuManager.map :my_menu do |menu|
  menu.push :account,
            { controller: '/my', action: 'account' },
            caption: :label_profile,
            icon: 'user'
  menu.push :settings,
            { controller: '/my', action: 'settings' },
            caption: :label_setting_plural,
            icon: 'settings2'
  menu.push :password,
            { controller: '/my', action: 'password' },
            caption: :button_change_password,
            if: Proc.new { User.current.change_password_allowed? },
            icon: 'locked'
  menu.push :access_token,
            { controller: '/my', action: 'access_token' },
            caption: I18n.t('my_account.access_tokens.access_tokens'),
            icon: 'key'
  menu.push :notifications,
            { controller: '/my', action: 'notifications' },
            caption: I18n.t('js.notifications.settings.title'),
            icon: 'bell'
  menu.push :reminders,
            { controller: '/my', action: 'reminders' },
            caption: I18n.t('js.reminders.settings.title'),
            icon: 'email-alert'

  menu.push :delete_account, :delete_my_account_info_path,
            caption: I18n.t('account.delete'),
            param: :user_id,
            if: Proc.new { Setting.users_deletable_by_self? },
            last: :delete_account,
            icon: 'delete'
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :admin_overview,
            { controller: '/admin', action: :index },
            if: Proc.new { User.current.admin? },
            caption: :label_overview,
            icon: 'home',
            first: true

  menu.push :users,
            { controller: '/users' },
            if: Proc.new { !User.current.admin? && User.current.allowed_to_globally?(:manage_user) },
            caption: :label_user_plural,
            icon: 'group'

  menu.push :placeholder_users,
            { controller: '/placeholder_users' },
            if: Proc.new { !User.current.admin? && User.current.allowed_to_globally?(:manage_placeholder_user) },
            caption: :label_placeholder_user_plural,
            icon: 'group'

  menu.push :users_and_permissions,
            { controller: '/users' },
            if: Proc.new { User.current.admin? },
            caption: :label_user_and_permission,
            icon: 'group'

  menu.push :user_settings,
            { controller: '/admin/settings/users_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_setting_plural,
            parent: :users_and_permissions

  menu.push :users,
            { controller: '/users' },
            if: Proc.new { User.current.admin? },
            caption: :label_user_plural,
            parent: :users_and_permissions

  menu.push :placeholder_users,
            { controller: '/placeholder_users' },
            if: Proc.new { User.current.admin? },
            caption: :label_placeholder_user_plural,
            parent: :users_and_permissions,
            enterprise_feature: 'placeholder_users'

  menu.push :groups,
            { controller: '/groups' },
            if: Proc.new { User.current.admin? },
            caption: :label_group_plural,
            parent: :users_and_permissions

  menu.push :roles,
            { controller: '/roles' },
            if: Proc.new { User.current.admin? },
            caption: :label_role_and_permissions,
            parent: :users_and_permissions

  menu.push :user_avatars,
            { controller: '/admin/settings', action: 'show_plugin', id: :openproject_avatars },
            if: Proc.new { User.current.admin? },
            caption: :label_avatar_plural,
            parent: :users_and_permissions

  menu.push :admin_work_packages,
            { controller: '/admin/settings/work_packages_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_work_package_plural,
            icon: 'view-timeline'

  menu.push :work_packages_setting,
            { controller: '/admin/settings/work_packages_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_setting_plural,
            parent: :admin_work_packages

  menu.push :types,
            { controller: '/types' },
            if: Proc.new { User.current.admin? },
            caption: :label_type_plural,
            parent: :admin_work_packages

  menu.push :statuses,
            { controller: '/statuses' },
            if: Proc.new { User.current.admin? },
            caption: :label_status,
            parent: :admin_work_packages,
            html: { class: 'statuses' }

  menu.push :workflows,
            { controller: '/workflows', action: 'edit' },
            if: Proc.new { User.current.admin? },
            caption: Proc.new { Workflow.model_name.human },
            parent: :admin_work_packages

  menu.push :custom_fields,
            { controller: '/custom_fields' },
            if: Proc.new { User.current.admin? },
            caption: :label_custom_field_plural,
            icon: 'custom-fields',
            html: { class: 'custom_fields' }

  menu.push :custom_actions,
            { controller: '/custom_actions' },
            if: Proc.new { User.current.admin? },
            caption: :'custom_actions.plural',
            parent: :admin_work_packages,
            enterprise_feature: 'custom_actions'

  menu.push :attribute_help_texts,
            { controller: '/attribute_help_texts' },
            caption: :'attribute_help_texts.label_plural',
            icon: 'help2',
            if: Proc.new { User.current.admin? },
            enterprise_feature: 'attribute_help_texts'

  menu.push :enumerations,
            { controller: '/enumerations' },
            if: Proc.new { User.current.admin? },
            icon: 'enumerations'

  menu.push :working_days,
            { controller: '/admin/settings/working_days_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_working_days,
            icon: 'calendar'

  menu.push :settings,
            { controller: '/admin/settings/general_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_system_settings,
            icon: 'settings2'

  SettingsHelper.system_settings_tabs.each do |node|
    menu.push :"settings_#{node[:name]}",
              { controller: node[:controller], action: :show },
              caption: node[:label],
              if: Proc.new { User.current.admin? },
              parent: :settings
  end

  menu.push :mail_and_notifications,
            { controller: '/admin/settings/aggregation_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :'menus.admin.mails_and_notifications',
            icon: 'mail1'

  menu.push :notification_settings,
            { controller: '/admin/settings/aggregation_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :'menus.admin.aggregation',
            parent: :mail_and_notifications

  menu.push :mail_notifications,
            { controller: '/admin/settings/mail_notifications_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :'menus.admin.mail_notification',
            parent: :mail_and_notifications

  menu.push :incoming_mails,
            { controller: '/admin/settings/incoming_mails_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_incoming_emails,
            parent: :mail_and_notifications

  menu.push :api_and_webhooks,
            { controller: '/admin/settings/api_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :'menus.admin.api_and_webhooks',
            icon: 'relations'

  menu.push :api,
            { controller: '/admin/settings/api_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_api_access_key_type,
            parent: :api_and_webhooks

  menu.push :authentication,
            { controller: '/admin/settings/authentication_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_authentication,
            icon: 'two-factor-authentication'

  menu.push :authentication_settings,
            { controller: '/admin/settings/authentication_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_setting_plural,
            parent: :authentication

  menu.push :ldap_authentication,
            { controller: '/ldap_auth_sources', action: 'index' },
            if: Proc.new { User.current.admin? && !OpenProject::Configuration.disable_password_login? },
            parent: :authentication,
            html: { class: 'server_authentication' },
            last: true

  menu.push :oauth_applications,
            { controller: '/oauth/applications', action: 'index' },
            if: Proc.new { User.current.admin? },
            parent: :authentication,
            caption: :'oauth.application.plural',
            html: { class: 'oauth_applications' }

  menu.push :announcements,
            { controller: '/announcements', action: 'edit' },
            if: Proc.new { User.current.admin? },
            caption: :label_announcement,
            icon: 'news'

  menu.push :plugins,
            { controller: '/admin', action: 'plugins' },
            if: Proc.new { User.current.admin? },
            last: true,
            icon: 'plugins'

  menu.push :backups,
            { controller: '/admin/backups', action: 'show' },
            if: Proc.new { OpenProject::Configuration.backup_enabled? && User.current.allowed_to_globally?(Backup.permission) },
            caption: :label_backup,
            last: true,
            icon: 'save'

  menu.push :info,
            { controller: '/admin', action: 'info' },
            if: Proc.new { User.current.admin? },
            caption: :label_information_plural,
            last: true,
            icon: 'info1'

  menu.push :custom_style,
            { controller: '/custom_styles', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_custom_style,
            icon: 'design',
            enterprise_feature: 'define_custom_style'

  menu.push :colors,
            { controller: '/colors', action: 'index' },
            if: Proc.new { User.current.admin? },
            caption: :'timelines.admin_menu.colors',
            icon: 'status'

  menu.push :enterprise,
            { controller: '/enterprises', action: :show },
            caption: :label_enterprise_edition,
            icon: 'enterprise-addons',
            if: proc { User.current.admin? && OpenProject::Configuration.ee_manager_visible? }

  menu.push :admin_costs,
            { controller: '/admin/settings', action: 'show_plugin', id: :costs },
            if: Proc.new { User.current.admin? },
            caption: :project_module_costs,
            icon: 'budget'

  menu.push :costs_setting,
            { controller: '/admin/settings', action: 'show_plugin', id: :costs },
            if: Proc.new { User.current.admin? },
            caption: :label_setting_plural,
            parent: :admin_costs

  menu.push :admin_backlogs,
            { controller: '/backlogs_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_backlogs,
            icon: 'backlogs'

  menu.push :backlogs_settings,
            { controller: '/backlogs_settings', action: :show },
            if: Proc.new { User.current.admin? },
            caption: :label_setting_plural,
            parent: :admin_backlogs
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.push :activity,
            { controller: '/activities', action: 'index' },
            if: Proc.new { |p| p.module_enabled?('activity') },
            icon: 'checkmark'

  menu.push :roadmap,
            { controller: '/versions', action: 'index' },
            if: Proc.new { |p| p.shared_versions.any? },
            icon: 'roadmap'

  menu.push :work_packages,
            { controller: '/work_packages', action: 'index' },
            caption: :label_work_package_plural,
            icon: 'view-timeline',
            html: {
              id: 'main-menu-work-packages',
              'wp-query-menu': 'wp-query-menu'
            }

  menu.push :work_packages_query_select,
            { controller: '/work_packages', action: 'index' },
            parent: :work_packages,
            partial: 'work_packages/menu_query_select',
            last: true,
            caption: :label_all_open_wps

  menu.push :news,
            { controller: '/news', action: 'index' },
            caption: :label_news_plural,
            icon: 'news'

  menu.push :forums,
            { controller: '/forums', action: 'index', id: nil },
            caption: :label_forum_plural,
            icon: 'ticket-note'

  menu.push :repository,
            { controller: '/repositories', action: :show },
            if: Proc.new { |p| p.repository && !p.repository.new_record? },
            icon: 'folder-open'

  # Wiki menu items are added by WikiMenuItemHelper

  menu.push :members,
            { controller: '/members', action: 'index' },
            caption: :label_member_plural,
            before: :settings,
            icon: 'group'

  menu.push :settings,
            { controller: '/projects/settings/general', action: :show },
            caption: :label_project_settings,
            last: true,
            icon: 'settings2',
            allow_deeplink: true

  {
    general: :label_information_plural,
    modules: :label_module_plural,
    types: :label_work_package_types,
    custom_fields: :label_custom_field_plural,
    versions: :label_version_plural,
    categories: :label_work_package_category_plural,
    repository: :label_repository,
    time_entry_activities: :enumeration_activities,
    storage: :label_required_disk_storage
  }.each do |key, caption|
    menu.push :"settings_#{key}",
              { controller: "/projects/settings/#{key}", action: 'show' },
              caption:,
              parent: :settings
  end
end
