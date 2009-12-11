class DashboardController < ApplicationController
  before_filter :conditions
  helper :hosts

  def index
    @total_hosts = Host.count
    @bad_hosts = Host.with("failed").count + Host.with("failed_restarts").count + Host.with("skipped").count
    @active_hosts = Host.with("applied").count +  Host.with("restarted").count
    @good_hosts = Host.count(:all, :conditions => @good_reports) - @bad_hosts
    @out_of_sync_hosts = Host.out_of_sync.count
    @intersting_reports = Report.count(:all, :conditions => @report_conditions)
    @interval = 3  # the run interval to show in the dashboard graph
    @puppet_runs = Report.count_puppet_runs(@interval)
  end

  def errors
    render :partial => "hosts/minilist", :layout => true, :locals => {
      :hosts => (Host.with("failed") + Host.with("failed_restarts") + Host.with("skipped")),
      :header => "Hosts with errors" }
  end

  def active
    render :partial => "hosts/minilist", :layout => true, :locals => {
      :hosts => (Host.with("applied") + Host.with("restarted")),
      :header => "Active Hosts" }
  end

  def OutOfSync
    render :partial => "hosts/minilist", :layout => true, :locals => {
      :hosts => Host.out_of_sync,
      :header => "Hosts which didnt run puppet in the last 30 minutes" }
  end



  private
  def conditions
    time = Time.now.utc - 35.minutes
    @sync_conditions = ["last_report < ? or last_report is ?", time, nil]
    @report_conditions = "status != 0"
    @good_reports = ["last_report > ? and puppet_status = ?", time, 0]
    @host_conditions = ["puppet_status > ?", 0]
  end

end

