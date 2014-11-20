require 'redmine'

class ZendeskListener < Redmine::Hook::Listener

  include ActionView::Helpers::IssuesHelper
  attr_accessor :controller, :request

  def controller_issues_edit_after_save(context)
    self.controller = context[:controller]
    self.request = context[:request]

    require 'zendesk_api'

    custom_field = CustomField.find(Setting.plugin_zendesk_plugin['field'])
    return unless custom_field

    journal = context[:journal]
    return unless journal

    issue = context[:issue]
    return unless issue && issue.custom_value_for(custom_field)

    zendesk_id = issue.custom_value_for(custom_field)
    return unless zendesk_id

    client = ZendeskAPI::Client.new do |config|
      config.url = Setting.plugin_zendesk_plugin['zendesk_url']
      config.username = Setting.plugin_zendesk_plugin['zendesk_username']
      config.password = Setting.plugin_zendesk_plugin['zendesk_password']
      config.retry = true
      require 'logger'
      config.logger = Logger.new(STDOUT)
    end

    issue_url = "#{Setting.plugin_zendesk_plugin['redmine_url']}/issues/#{issue.id}"
    comment = "Redmine ticket #{issue_url} was updated by #{journal.user.name}:\n\n"

    for detail in journal.details
      comment << show_detail(detail, true) rescue ''
      comment << "\n"
    end

    if journal.notes && !journal.notes.empty?
      comment << journal.notes
    end

    ticket = client.requests.find(:id => zendesk_id)
    ticket.comment = { :body => comment}
    ticket.save

  end

end