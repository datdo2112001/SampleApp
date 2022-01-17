class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable , omniauth_providers: [:facebook, :google_oauth2]

	has_many :microposts, dependent: :destroy
  	has_many :active_relationships, class_name:  "Relationship",
                                  	foreign_key: "follower_id",
                                  	dependent:   :destroy
  	has_many :passive_relationships, class_name:  "Relationship",
                                   	foreign_key: "followed_id",
                                   	dependent:   :destroy
  	has_many :following, through: :active_relationships,  source: :followed
  	has_many :followers, through: :passive_relationships, source: :follower

	attr_accessor :remember_token, :activation_token, :reset_token
	before_save :downcase_email
	before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
							format: { with: VALID_EMAIL_REGEX },
							uniqueness: true

	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
													  BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def authenticated?(attribute, token)
    	digest = send("#{attribute}_digest")
    	return false if digest.nil?
    	BCrypt::Password.new(digest).is_password?(token)
  	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def session_token
		remember_digest || remember
	end

	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end
	# Sends activation email.
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end
	# Sends password reset email.
	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def feed
    Micropost.where("user_id IN (SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id)
                     OR user_id = :user_id", user_id: id)
  	end

	# Follows a user.
  	def follow(other_user)
    	following << other_user
  	end

  	# Unfollows a user.
  	def unfollow(other_user)
    	following.delete(other_user)
  	end

  	# Returns true if the current user is following the other user.
  	def following?(other_user)
    	following.include?(other_user)
  	end

  def self.from_omniauth(auth)
    result = User.where(email: auth.info.email).first
    if result
      return result
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.name = auth.info.name
        user.password = Devise.friendly_token[0,20]
        user.image = auth.info.image
        user.uid = auth.uid
        user.provider = auth.provider
      end
    end
  end


	private
		# Converts email to all lower-case.
		def downcase_email
			self.email = email.downcase
		end
		# Creates and assigns the activation token and digest.
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end

end
