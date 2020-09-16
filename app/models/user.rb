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
  
  
  validates :basic_work_time, presence: true
  has_secure_password
  validates :password, length: { maximum: 10 }, allow_nil: true
  
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
  
  # ランダムなトークンを返し��す。
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
    imported_num = 0
    
    open(file.path, 'r:cp932:utf-8', undef: :replace) do |f|
      csv = CSV.new(f, :headers => :first_row)
      caches = User.all.index_by(&:id)
      # begin
        csv.each do |row|
          next if row.header_row?
          table = Hash[[row.headers, row.fields].transpose]
          
          # user = find_by(email: table["email"])
          user = caches[table['id']]
          if user.nil?
            user = new
          end
          
          user.attributes = table.to_hash.slice(*table.to_hash.except(:email, :created_at, :updated_at).keys)
          
          if user.valid?
            user.save!
            imported_num += 1
          end
        end
      # rescue
      # end
    end
    imported_num
  end
  
  def self.updatable_attributes
    ["name", "email", "password", "admin", "superior", "uid", "employee_number", "affiliation",
    "basic_work_time", "designated_work_start_time", "designated_work_end_time"]
  end


 
end
