class EndUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :posts
  has_many :post_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy

  # 自分がフォローされる（被フォロー）側の関係性
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # 被フォロー関係を通じて参照→自分をフォローしている人
  has_many :followers, through: :reverse_of_relationships, source: :follower

  # 自分がフォローする（与フォロー）側の関係性
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # 与フォロー関係を通じて参照→自分がフォローしている人
  has_many :followings, through: :relationships, source: :followed

  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }
  validates :disorder, length: { minimum: 2, maximum: 50 }
  validates :express, length: { maximum: 200 }


  scope :only_active, -> { where(is_active: true) }


  def follow(end_user)
    relationships.create(followed_id: end_user.id)
  end

  def unfollow(end_user)
    relationships.find_by(followed_id: end_user.id).destroy
  end

  def following?(end_user)
    followings.include?(end_user)
  end

  def self.search_for(content, method)
    if method == 'perfect'
      EndUser.where(name: content)
    elsif method == 'forward'
      EndUser.where('name LIKE ?', content + '%')
    elsif method == 'backward'
      EndUser.where('name LIKE ?', '%' + content)
    else
      EndUser.where('name LIKE ?', '%' + content + '%')
    end
  end


  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'no_image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_limit: [width, height]).processed
  end



end
