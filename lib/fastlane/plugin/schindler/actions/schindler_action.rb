require 'fastlane/action'
require_relative '../helper/schindler_helper'
require 'spaceship'
require 'json'

module Fastlane
  module Actions
    class SchindlerAction < Action
      Filter_Uninstall = 1 << 0
      Filter_Expire = 1 << 1
      Filter_UnUse = 1 << 2

      def self.run(params)
        UI.message('The schindler plugin is working!')

        ARGV.clear

        filter_type = params[:filter_type].to_i
        auto_confirm = params[:auto_confirm].to_s == 'auto'
        user_id = params[:user_id].to_s
        user_password = params[:user_password].to_s
        ios_app_id = params[:ios_app_id].to_s
        puts "================================\n新建名单，初始化参数信息：\n筛选类型(位运算)：#{filter_type}  (#{Filter_Uninstall}-未安装，#{Filter_Expire}-已过期，#{Filter_UnUse}-未使用)\n跳过二次确认：#{auto_confirm}\n账号：#{user_id}\n密码：******\n应用ID：#{ios_app_id}\n================================"

        # 先扫描未安装、已过期
        if (filter_type & Filter_Uninstall > 0) || (filter_type & Filter_Expire > 0)
          add_process_uninstall_expired(filter_type: filter_type, auto_confirm: auto_confirm, ios_app_id: ios_app_id,
                                        user_id: user_id, user_password: user_password)
        end
        # 再扫描未使用，因为未使用需要全量查询，耗时1小时起步，容易超时
        # if filter_type & Filter_UnUse > 0
        #   add_process_unused(auto_confirm: auto_confirm, ios_app_id: ios_app_id, user_id: user_id,
        #                      user_password: user_password)
        # end
      end

      def self.exec_process(testers, filter_type, auto_confirm)
        return [] if testers.nil?

        ids = []
        # 90天前的安装
        currentDate = DateTime.now.to_time
        expiredtime = (currentDate - 60 * 60 * 24 * 90).to_i
        # 7天内更新的，不统计打开次数
        sevendaytime = (currentDate - 60 * 60 * 24 * 7).to_i

        testers.each do |tester|
          # puts "测试员信息：#{tester.to_json}"

          unless tester.respond_to?(:beta_tester_state)
            puts "\n\n~~~~~~~~~~ 异常跳过：不合法的BetaTester数据 ~~~~~~~~~~"
            next
          end

          id = tester.id.to_s
          tester_state = tester.beta_tester_state
          puts "测试员：#{tester.id} 状态-#{tester_state}"

          if tester.beta_tester_state == "INSTALLED"
            modified_date = string2date(tester.last_modified_date)
            next if modified_date.nil?

            last_date = modified_date.getlocal.to_i
            puts "最后更新时间：#{modified_date}"
            # 在sevenDaySessionCount支持前，暂时用session_count + lastModifiedDate
            # session_count被苹果废弃， by hongtao 2023/08/09
            # count = tester.session_count.to_i

            if (filter_type & Filter_Expire) > 0 && last_date < expiredtime
              # 过期
              ids << id

              puts '===== 已过期 +1 ====='
            # elsif (filter_type & Filter_UnUse) > 0 && count < 1 && last_date < sevendaytime
            #   # 超过7天未使用
            #   ids << id

            #   puts '===== 未使用 +1 ====='
            end
          elsif filter_type & Filter_Uninstall > 0
            ids << id

            puts '===== 未安装 +1 ====='
          end
        end

        puts "\n测试员筛选完成\n================================"
        if ids.size < 1
          puts "当前规则下，测试员已经删完干净了\n================================"
          return []
        end

        unless auto_confirm
          puts "删除TestFlight测试员：#{ids.size}个？ (Y/n)"
          if gets.chomp != 'Y'
            puts "Cancel，任务取消，此次任务结束\n================================"
            return []
          end
        end

        return ids
      end

      def self.string2date(origin_date_string)
        modified_date_string = origin_date_string
        # 在removeAfterDate支持前，暂时用lastModifiedDate. "last_modified_date":"2022-09-02T07:05:44.414-07:00"
        modified_date = nil
        # 为兼容没有毫秒的数据，统一干掉毫秒，苹果也不标准啊！
        date_string_split = modified_date_string.split('.')
        if date_string_split.size == 2
          parse_string = date_string_split[1]
          parse_string_split = parse_string.split('-')
          if parse_string_split.size > 1
            parse_string = '-' + parse_string_split[1]
          else
            puts "不合法的lastModifiedDate： #{origin_date_string}"
            return modified_date
          end

          modified_date_string = date_string_split[0]
          modified_date_string.concat(parse_string)
        end

        if modified_date_string.length == 25
          modified_date = DateTime.strptime(modified_date_string, '%Y-%m-%dT%H:%M:%S%z').to_time
        else
          puts "不合法的lastModifiedDate： #{origin_date_string}"
          return modified_date
        end

        modified_date
      end

      # def self.add_process_unused(auto_confirm: false, ios_app_id: nil, user_id: nil, user_password: nil)
      #   # 查询全量数据，但容易超时，未使用的用户只能全量查询
      #   puts "#{DateTime.now.to_time} 开始获取App数据……"
      #   app = Spaceship::ConnectAPI::App.get(app_id: ios_app_id)

      #   puts "#{DateTime.now.to_time} 开始获取测试人员列表，带薪喝茶时间……"
      #   testers = nil
      #   if app
      #     puts 'App get_beta_testers'
      #     testers = app.get_beta_testers(filter: { apps: ios_app_id, isDeleted: false }, includes: 'betaTesterMetrics',
      #                                    sort: 'betaTesterMetrics.betaTesterState', limit: 20)
      #   else
      #     puts 'Spaceship::ConnectAPI::BetaTester'
      #     testers = Spaceship::ConnectAPI::BetaTester.all(filter: { apps: ios_app_id, isDeleted: false },
      #                                                     includes: 'betaTesterMetrics', sort: 'betaTesterMetrics.betaTesterState', limit: 200)
      #   end
      #   puts "#{DateTime.now.to_time} 获取测试人员列表成功，共#{testers.count}个"

      #   ids = exec_process(testers, Filter_UnUse, auto_confirm)
      #   return if ids.size < 1

      #   itc_team_id = '82324800'
      #   team_id = "9SR35Y6UHD"
      #   # 每次查询Top 50，直到没有符合的记录，适合按状态排序后的扫描
      #   client = Spaceship::ConnectAPI::Client.login(user_id, user_password, portal_team_id: team_id, tunes_team_id: itc_team_id)
      #   puts '登录成功'
      #   client.delete_beta_testers_from_app(beta_tester_ids: ids, app_id: ios_app_id)
      #   puts "Success，删除#{ids.size}个测试人员成功\n================================"
      # end

      def self.add_process_uninstall_expired(filter_type: (Filter_Uninstall | Filter_Expire), auto_confirm: false, ios_app_id: nil, user_id: nil, user_password: nil)
        itc_team_id = params[:portal_team_id].to_s
        team_id = params[:itc_team_id].to_s
        # 每次查询Top 50，直到没有符合的记录，适合按状态排序后的扫描
        client = Spaceship::ConnectAPI::Client.login(user_id, user_password, portal_team_id: team_id, tunes_team_id: itc_team_id)
        puts 'ConnectAPI 登录成功'

        deleteCount = 0
        while true
          puts "#{DateTime.now.to_time} 开始获取测试人员列表，带薪喝茶时间……"
          testers = client.get_beta_testers(filter: { apps: ios_app_id, isDeleted: false },
                                            includes: 'betaTesterMetrics', sort: 'betaTesterMetrics.betaTesterState')

          puts "#{DateTime.now.to_time} 获取测试人员列表成功，共#{testers.count}个"

          ids = exec_process(testers, filter_type, auto_confirm)
          if ids.size < 1
            puts "未安装 or 已过期 测试员清除完毕\n================================"
            return
          end

          begin
            client.delete_beta_testers_from_app(beta_tester_ids: ids, app_id: ios_app_id)
            rescue => e
              puts "delete error, but the program continues to execute. exception detail: #{e}"
          end
          deleteCount = deleteCount + ids.size
        end

        puts "Success，删除#{deleteCount}个测试人员成功\n================================"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Schindler is a TestFlight tool for release useless quota.'
      end

      def self.authors
        ['xjk_001@163.com']
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        'Remove TestFlight testers that are not actually testing your app. Schindler is a TestFlight automatic processing tool, which is used to maintain the number of TestFlight quota, eliminate useless testers, and improve the external gray effect of iOS App.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :filter_type,
                                       env_name: 'SCHINDLER_FILTER_TYPE',
                                       description: "'1'-Not installed, '2'-Expired, '3'-All(1 | 2), default 7",
                                       optional: true,
                                       default_value: '3',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :auto_confirm,
                                       env_name: 'SCHINDLER_AUTO_CONFIRM',
                                       description: "'auto'-skip, default no. Skip the second confirmation, or wait for user confirmation before deleting after scanning (optional)",
                                       optional: true,
                                       default_value: 'none',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :user_id,
                                       env_name: 'SCHINDLER_USER_ID',
                                       description: 'Your AppID for login Connect',
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :user_password,
                                       env_name: 'SCHINDLER_PASSWORD',
                                       description: 'AppID password, support App private password (optional)',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :ios_app_id,
                                       env_name: 'SCHINDLER_APP_ID',
                                       description: 'The ID of the app in the Apple Store',
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :portal_team_id,
                                       env_name: 'SCHINDLER_PORTAL_TEAM_ID',
                                       description: 'Developer Portal Team ID (optional)',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :itc_team_id,
                                      env_name: 'SCHINDLER_ITC_TEAM_ID',
                                      description: 'App Store Connect Team ID (optional)',
                                      optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        %i[ios mac].include?(platform)
        # true
      end

      def self.example_code
        [
          'schindler(
            filter_type: "3",               # Optional, eliminate useless testers
            auto_confirm: "auto",           # Optional, Skip the second confirmation
            user_id: "my_username",         # My AppID
            user_password: "my_password",   # Optional, My password
            ios_app_id: "my_ios_app",       # The App which to be eliminated
            portal_team_id: "my_team_id",   # Optional, Developer Portal Team ID
            itc_team_id: "my_itc_team_id"   # Optional, App Store Connect Team ID
          )'
        ]
      end
    end
  end
end
