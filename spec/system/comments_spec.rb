require 'rails_helper'

RSpec.describe "コメント投稿機能", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @prototype = FactoryBot.create(:prototype)
    @comment = Faker::Lorem.sentence
  end

  context '送信に失敗した時' do
    it '送る値が空だと、コメントの送信に失敗する' do
      # ログインする
      sign_in(@user)
      # プロトタイプの画像をクリックする
      all(".card__img")[0].click
      #プロトタイプ詳細ページへ遷移したことを確認
      expect(current_path).to eq(prototype_path(@prototype))
      expect(page).to have_selector('img')
      expect(page).to have_content(@prototype.title)
      expect(page).to have_content(@prototype.catch_copy)
      expect(page).to have_content(@prototype.concept)
      expect(page).to have_content('コメント')
      # コメントの投稿フォームがある事を確認
      expect(page).to have_selector '#comment_content'
      # コメントをからのまま送信ボタンを押してもDBに保存されていないことを確認する'
      expect{
        find('input[name="commit"]').click
      }.not_to change { Comment.count} 
      # 元のページに戻ってくることを確認する
      expect(current_path).to eq(prototype_comments_path(@prototype))
    end
    it 'ログインしていないとコメント投稿フォームが表示されない' do
      # トップページにいく
      visit root_path
      # プロトタイプ画像をクリックする
      all(".card__img")[0].click
      # プロトタイプ詳細ページに遷移したことを確認する
      expect(current_path).to eq(prototype_path(@prototype))
      expect(page).to have_selector('img')
      expect(page).to have_content(@prototype.title)
      expect(page).to have_content(@prototype.catch_copy)
      expect(page).to have_content(@prototype.concept)
      # コメントの投稿フォームがないことを確認
      expect(page).to have_no_selector '#comment_content'
      end
  end
  context '送信に成功する時' do
    it 'ログインしているユーザーがコメント投稿フォームに１文字以上の文章を入力して送信すると成功する' do
      # ログインする
      sign_in(@user)
      # プロトタイプの画像をクリックする
      all(".card__img")[0].click
      #プロトタイプ詳細ページへ遷移したことを確認
      expect(current_path).to eq(prototype_path(@prototype))
      expect(page).to have_selector('img')
      expect(page).to have_content(@prototype.title)
      expect(page).to have_content(@prototype.catch_copy)
      expect(page).to have_content(@prototype.concept)
      expect(page).to have_content('コメント')
      # コメントの投稿フォームがある事を確認
      expect(page).to have_selector '#comment_content'
      fill_in 'comment_content' , with: @comment
      expect{
        find('input[name="commit"]').click
      }.to change { Comment.count }.by(1) 
      # 元のページに戻ってくることを確認する
      expect(current_path).to eq(prototype_path(@prototype))
      # 詳細ページに先ほどのコメントが含まれていることを確認
      expect(page).to have_content @comment
      binding.pry
      expect(page).to have_selector '.comment_user',text: @user.name
    end
  end
end
      