require 'rails_helper'

RSpec.describe "ユーザー新規登録機能", type: :system do
  before do
    driven_by(:selenium_chrome)
  end
  context '新規登録に成功する時' do
    it '必要な情報を入力して新規登録にせいこうする' do
      visit root_path
      expect(page).to have_link('新規登録')
      expect(page).to have_link('ログイン')
  
      @user = FactoryBot.build(:user)
      # 新規登録画面に遷移する
      visit root_path
      click_on('新規登録')
      # 必要な情報を埋めると新規登録が成功してトップページに遷移する
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      fill_in 'user_password_confirmation', with: @user.password
      fill_in 'user_name', with: @user.name
      fill_in 'user_profile', with: @user.profile
      fill_in 'user_occupation', with: @user.occupation
      fill_in 'user_position', with: @user.position
      expect{
        find('input[name="commit"]').click
      }.to change { User.count }.by(1)
      sleep 1

      expect(current_path).to eq(root_path)
      
      # 登録したユーザー名が表示されている
      expect(page).to have_content("こんにちは、 #{@user.name}さん")

      #トップページ状にログアウトボタンと新規投稿ボタンが存在する  
      expect(page).to have_content('ログアウト')
      expect(page).to have_content('New Proto')
    end
  end
  context '新規登録に失敗する時' do

    it '必要な情報を空で送信した時' do
      # 新規登録画面に遷移する
      visit root_path
      click_on('新規登録')
      # 必要な情報を埋めずに新規登録ボタンを押すと登録に失敗して新規登録画面に戻ってくる
      click_button '新規登録'
      sleep 1
  
      expect(current_path).to eq(user_registration_path)
    end
  end
end

RSpec.describe "ユーザーログイン機能", type: :system do
  before do
    driven_by(:selenium_chrome)
  end
  context 'ログインに成功するとき' do
    it 'ログインに成功し、トップページに遷移する' do
      # DBにユーザー情報をあらかじめ保存しておく
      @user = FactoryBot.create(:user)
      # ログイン画面に遷移する
      visit root_path
      click_on('ログイン')
      # 必要な情報を埋めるとログインが成功してトップページに遷移する
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click
      sleep 1
  
      expect(current_path).to eq(root_path)
    
      # 登録したユーザー名が表示されている
      expect(page).to have_content(@user.name)

      #トップページ状にログアウトボタンと新規投稿ボタンが存在する
      expect(page).to have_content('ログアウト')
      expect(page).to have_content('New Proto')
    end

  
    it 'ログインに失敗し、再びログイン画面に戻ってくる' do
      # 新規登録画面に遷移する
      visit root_path
      click_on('ログイン')
      # 必要な情報を埋めずに新規登録ボタンを押すと登録に失敗して新規登録画面に戻ってくる
      find('input[name="commit"]').click
      sleep 1

      expect(current_path).to eq(user_session_path)
    end
  end
end

RSpec.describe "ユーザー管理機能", type: :system do
  before do
    driven_by(:selenium_chrome)
    @prototype = FactoryBot.create(:prototype)
    @user = FactoryBot.create(:user)
  end
  context 'ログインしていないときのバリデーション' do
    it 'ログインしていない状態では、プロトタイプ新規投稿ページに遷移しようとするとログイン画面にリダイレクトされる' do
       visit new_prototype_path
       expect(current_path).to eq(user_session_path)
    end

    it 'ログインしていない状態では、プロトタイプの編集ページに遷移しようとするとログイン画面にリダイレクトされる' do
      
      visit edit_prototype_path(@prototype.id)
      expect(current_path).to eq(user_session_path)
    end

    it'ログインしていない状態でも、トップページに遷移できている' do
      visit root_path
      expect(current_path).to eq(root_path)
    end
  
    it 'ログインしていない状態でも、プロトタイプの詳細ページに遷移できる' do
      
      visit root_path
      expect(page).to have_content(@prototype.title)
      click_on(@prototype.title)

      expect(current_path).to eq(prototype_path(@prototype.id))
    end
  
    it 'ログインしていない状態でも、ユーザー詳細ページに遷移できる' do
      
      visit user_path(@user.id)
      expect(current_path).to eq(user_path(@user.id))
    end
  end
  context 'ログインしているときの制限' do
    it 'ログインしていても他のユーザーの投稿したプロトタイプは編集できないでトップ画面にリダイレクトされる' do
      sign_in(@user)
      visit edit_prototype_path(@prototype.id)
      expect(current_path).to eq(root_path)
    end
  end
end
RSpec.describe "ユーザー管理機能", type: :system do
  before do
    driven_by(:selenium_chrome)
    @user = FactoryBot.create(:user)
    @prototype = FactoryBot.create(:prototype, user: @user)
  end
  context 'ログインしているときユーザー詳細ページへ遷移する' do
    it 'ログインしているユーザー名をクリックするとユーザー詳細ページに遷移する' do
      sign_in(@user)
      all(".card__user")[0].click
      click_on(@user.name)
      expect(current_path).to eq(user_path(@user.id))
      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.profile)
      expect(page).to have_content(@user.occupation)
      expect(page).to have_content(@user.position)
      expect(page).to have_content(@prototype.title)
      expect(page).to have_content(@prototype.catch_copy)
    end
  end
  context 'ログインしていない場合もユーザー詳細ページに遷移できる' do
    it 'ログインしていない場合でもユーザー名をクリックするとユーザー詳細ページに遷移する' do
      visit root_path
      all(".card__user")[0].click
      expect(current_path).to eq(user_path(@user.id))
      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.profile)
      expect(page).to have_content(@user.occupation)
      expect(page).to have_content(@user.position)
      expect(page).to have_content(@prototype.title)
      expect(page).to have_content(@prototype.catch_copy)
    end
     
  end
end
  


 