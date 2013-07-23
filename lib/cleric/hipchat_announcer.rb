module Cleric
  class HipChatAnnouncer
    def initialize(config, listener, user)
      @config = config
      @listener = listener
      @user = user
    end

    def chatroom_added_to_repo(repo, chatroom)
      @listener.chatroom_added_to_repo(repo, chatroom)
      send_message(%Q[Repo "#{repo}" notifications will be sent to chatroom "#{chatroom}", set by "#{@user}"])
    end

    def repo_added_to_team(repo, team)
      @listener.repo_added_to_team(repo, team)
      send_message(%Q[Repo "#{repo}" added to team "#{team}" by "#{@user}"])
    end

    def repo_created(repo)
      @listener.repo_created(repo)
      send_message(%Q[Repo "#{repo}" created by "#{@user}"])
    end

    def user_added_to_team(username, team)
      @listener.user_added_to_team(username, team)
      send_message(%Q[User "#{username}" added to team "#{team}" by "#{@user}"])
    end

    def user_removed_from_org(username, email, org)
      @listener.user_removed_from_org(username, email, org)
      send_message(%Q[User "#{username}" (#{email}) removed from organization "#{org}" by "#{@user}"], :red)
    end

    private

    def hipchat
      @hipchat ||= HipChat::API.new(@config.hipchat_api_token)
    end

    def send_message(description, color = :green)
      hipchat.rooms_message(
        @config.hipchat_announcement_room_id, 'Cleric', description, 0, color.to_s, 'text'
      )
    end
  end
end
