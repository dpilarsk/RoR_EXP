class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:marvin]
    
    def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
        user.login = auth.info.nickname
        user.email = user.login + "@student.42.fr"
        user.password = Devise.friendly_token[0,20]
        user.location = auth.info.location
        user.wallets = auth.extra.raw_info.wallet
        user.staff = auth.extra.raw_info.staff?
      end
    end
end
