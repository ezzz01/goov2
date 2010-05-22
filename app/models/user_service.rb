#class for dealing with avatar upload
class UserService
    attr_reader :user, :avatar

    def initialize(user, avatar)
        @user = user 
        @avatar = avatar 
    end

    def save
        return false unless valid?
        begin
            User.transaction do
                if @avatar.new_record?
                    @user.avatar.destroy if @user.avatar
                    @avatar.user = @user
                    @avatar.save!
                end
                @user.save!
                true
            end
        rescue
            false
        end
    end

    def update_attributes(user_attributes, avatar_file)
        @user.attributes = user_attributes
        if avatar_file.blank?
            @user.save!
        else 
            @avatar = Avatar.new(:uploaded_data => avatar_file)
            save
        end
    end

    def valid?
        @user.valid? && @avatar.valid?
    end

end
