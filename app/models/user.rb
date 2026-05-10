class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token,:reset_token
  before_save :downcase_email
  #saveが呼ばれるたびに何回もやる
  before_create :create_activation_digest
  #create : 初回データをDBに保存する直前
  #controller(User.newを呼ぶ => saveを呼ぶ) => model(バリデーション=>before_createをやる=>DB保存)
  #
  validates :name,presence:true,length:{maximum:50}
  VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,presence:true,length:{maximum:255},
                  format: {with: VALID_EMAIL_REGEX},
                  uniqueness: true
  has_secure_password
  validates :password, presence:true, length: { minimum: 6 },allow_nil: true


  #渡された文字列のハッシュ値を返す
  def self.digest(string) #このselfはuser
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST:
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string,cost:cost)
  end

  def self.new_token 
    SecureRandom.urlsafe_base64
  end

  #永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token #関数
    #selfは今操作してる一人のユーザーオブジェクト
    update_attribute(:remember_digest,User.digest(remember_token))
    remember_digest#ユーザーごとの一意の値として使っていく
  end

  #セッションハイジャック防止のためにセッショントークンを返す
  def session_token
    remember_digest || remember
  end


  #渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute,token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
    #DBのcolumnとかつかって判断してるからこれはmodelに書くよ
    #BCrypt::Password.new(digest) => 復元.new(digest)はこのハッシュを
    #BCryptとして扱えるオブジェクトに変換する
    #is_password?はハッシュと一致してるかチェック
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest,nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
    #一回で情報を2つ変える
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
#ユーザー新規設定時じゃないのでbefore_createはやらない
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  #パスワードの再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago #2.hours.ago => 二時間前
    #よりもさらに前の時刻
  end

  def feed 
    Micropost.where("user_id = ?",id )
    #Micropostテーブルからuser_idがこのユーザー(id)と同じ投稿
    #session[:user_id]=user.idで, current_userが橋渡ししてる
    #user_idはMicropostDBのカラム名
  
  end

  private

    def downcase_email
      self.email.downcase!
    end

    #有効かトークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      #def activation_token
      #    @activation_token
      #end attr_accessorのgetでこれが可能
      #この段階はDBに保存してないよ
      self.activation_digest = User.digest(activation_token)
    end

    
end
