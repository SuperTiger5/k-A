class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :affiliation, length: { in: 2..30 }, allow_blank: true
  VALID_UID_REGEX = /\A[a-z0-9]+\z/
  validates :uid, presence: true,
                  format: { with: VALID_UID_REGEX },
                  uniqueness: true
  validates :employee_number, presence: true,
                              numericality: {only_integer: true}
  
  validates :basic_time, presence: true
  validates :basic_work_time, presence: true
  has_secure_password
  validates :password, length: { maximum: 10 }, allow_nil: true
  
  validate :basic_work_time_than_basic_time
  
  def basic_work_time_than_basic_time
      errors.add(:basic_time, "より長い指定勤務時間は無効です") if basic_work_time > basic_time
  end
   # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
   # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
   def remember
     # ランダムな文字列をremember_tokenに代入
     self.remember_token = User.new_token
     # remember_token(仮想カラム)　→　remember_digest(DB)
     update_attribute(:remember_token, User.digest(remember_token))
   end
   
  # 永続的セッションに保存しているremember_tokenがDBのremember_digestと一致しているか
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def self.search(search) #ここでのself.はUser.を意味する
    if search
      where(['name LIKE ?', "%#{search}%"]) #検索とnameの部分一致を表示。User.は省略
    else
      all #全て表示。User.は省略
    end
  end
  
  def self.import(file)
     CSV.foreach(file.path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      # IDが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
      user = find_by(id: row["id"]) || new
      # CSVからデータを取得し、設定する
      user.attributes = row.to_hash.slice(*updatable_attributes)
      # 保存する
      user.save
     end
  end
  
  def self.updatable_attributes
    ["name", "email",	"affiliation","uid", "basic_work_time",
     "designated_work_start_time",	"designated_work_end_time",	"superior",	"admin", "password"
    ]
  end
end
