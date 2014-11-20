require 'redmine'
require File.dirname(__FILE__) + '/lib/zendesk_client'

Redmine::Plugin.register :zendesk_plugin do
  name 'Zendesk plugin'
  author 'Rikard Gynnerstedt'
  description 'Updates associated Zendesk tickets when Redmine issues are updated'
  version '0.0.1'
  settings :default => {
      'zendesk_url' => 'http://support.zendesk.com/api/v2',
      'zendesk_username' => 'zendeskuser',
      'zendesk_password' => 'zendeskpassword',
      'field' => nil,
      'redmine_url' => 'https://your.redmine.url/'
    },
    :partial => 'settings/zendesk_plugin_settings'
end
