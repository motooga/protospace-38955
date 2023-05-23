require 'rails_helper'

RSpec.describe "プロトタイプ新規投稿機能", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @prototype1 = FactoryBot.create(:prototype, user: @user)
    @prototype = FactoryBot.build(:prototype)
  end

  context '投稿に失敗した時' do
    it '投稿に必要な情報が入力されていない場合は、投稿できずにそのページに留まること' do
      # ログインする
      sign_in(@user)
      click_on('New Proto')
      expect(current_path).to eq(new_prototype_path)
      expect{
        find('input[name="commit"]').click
      }.not_to change { Prototype.count }
      # 元のページに戻ることを確認
      expect(current_path).to eq(prototypes_path)
      
    end

    it '投稿に失敗した時に戻ったページに入力済みの項目は消えない' do
      sign_in(@user)
      click_on('New Proto')
      expect(current_path).to eq(new_prototype_path)
      fill_in 'prototype_title', with: @prototype.title
      fill_in 'prototype_catch_copy', with: @prototype.catch_copy
      fill_in 'prototype_concept', with: @prototype.concept
      expect{
        find('input[name="commit"]').click
      }.not_to change { Prototype.count}
      expect(find('#prototype_title').value).to eq(@prototype.title)
      expect(find('#prototype_catch_copy').value).to eq(@prototype.catch_copy)
      expect(find('#prototype_concept').value).to eq(@prototype.concept)
    end
  end
  context '投稿に成功した時' do
    it '投稿に必要な情報を入力すると投稿が成功する' do
      # 添付する画像を定義する
      image_path = Rails.root.join('public/images/test-image.png')
      sign_in(@user)
      click_on('New Proto')
      expect(current_path).to eq(new_prototype_path)
      fill_in 'prototype_title', with: @prototype.title
      fill_in 'prototype_catch_copy', with: @prototype.catch_copy
      fill_in 'prototype_concept', with: @prototype.concept
      attach_file('prototype[image]', image_path, make_visible: true)
      expect {
        find('input[name="commit"]').click
        sleep 1
      }.to change {Prototype.count}.by(1)

      #トップページに遷移していることを確認する
      expect(current_path).to eq(root_path)

      #投稿したプロトタイプがブラウザに表示されていることを確認する
      expect(page).to have_selector('img')
      expect(page).to have_content(@prototype.title)
      expect(page).to have_content(@prototype.catch_copy)
      expect(all('.card__user')[1]).to have_content("by#{@user.name}")

    end
  end
end

RSpec.describe 'プロトタイプ詳細ページ機能', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @prototype1 = FactoryBot.create(:prototype, user: @user)
  end

  context '' do
    it 'ログインしている場合一覧表示している画像およびプロトタイプ名から詳細ページへ飛ぶ' do
      sign_in(@user)
      expect(current_path).to eq(root_path)

      expect(page). to have_selector('.card__img')
      expect(page).to have_link(@prototype1.title, href: prototype_path(@prototype1) , class: 'card__title', visible: true)
      # プロトタイプの情報（タイトル、投稿者、画像、キャッチコピー、コンセプト）が表示されている
      visit prototype_path(@prototype1)
      expect(page).to have_selector('img')
      expect(page).to have_content(@prototype1.title)
      expect(page).to have_content(@prototype1.catch_copy)
      expect(page).to have_content(@prototype1.concept)
      # 投稿ユーザーがcurrent_userと一致する場合だけ「編集」「削除」リンクが存在する

      expect(page).to have_link('編集する', href: edit_prototype_path(@prototype1))
      expect(page).to have_link('削除する', href: prototype_path(@prototype1))
      # 画像がリンク切れになっていない
    
    end
    it 'ログインしていない場合でも詳細ページへ遷移できる' do
      # プロトタイプの情報（タイトル、投稿者、画像、キャッチコピー、コンセプト）が表示されている
      visit root_path
      expect(page). to have_selector('.card__img')
      expect(page).to have_link(@prototype1.title, href: prototype_path(@prototype1) , class: 'card__title', visible: true)
      visit prototype_path(@prototype1)
      expect(page).to have_selector('img')
      expect(page).to have_content(@prototype1.title)
      expect(page).to have_content(@prototype1.catch_copy)
      expect(page).to have_content(@prototype1.concept)
      # 画像がリンク切れになっていない

      # 編集、削除ボタンが存在しない
      expect(page).to have_no_link('編集する', href: edit_prototype_path(@prototype1))
      expect(page).to have_no_link('削除する', href: prototype_path(@prototype1))

    end
  end
end
RSpec.describe 'プロトタイプ編集機能', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @prototype1 = FactoryBot.create(:prototype, user: @user)
  end
  context '編集が成功する時' do
    it 'ログインしているユーザーとプロトタイプの投稿ユーザーと一致している時投稿に必要な情報を入力すると編集ができる' do
      sign_in(@user)
      visit prototype_path(@prototype1)
      expect(page).to have_link('編集する', href: edit_prototype_path(@prototype1))
      click_on('編集する')
      sleep 1
      expect(current_path).to eq(edit_prototype_path(@prototype1))
      # 登録した内容がすでに入っていることを確認する
      expect(find('#prototype_title').value).to eq(@prototype1.title)
      expect(find('#prototype_catch_copy').value).to eq(@prototype1.catch_copy)
      expect(find('#prototype_concept').value).to eq(@prototype1.concept)

      # 何も編集せずに更新しても、画像なしのプロトタイプにならず詳細ページへ遷移する
      click_on('保存する')
      expect(current_path).to eq(prototype_path(@prototype1))
      expect(page).to have_selector('img')

    end
    it '編集に必要な情報をすべて書き換えて保存すると編集に成功して詳細ページへ遷移' do
      sign_in(@user)
      visit prototype_path(@prototype1)
      expect(page).to have_link('編集する', href: edit_prototype_path(@prototype1))
      click_on('編集する')
      sleep 1
      expect(current_path).to eq(edit_prototype_path(@prototype1))
      # 登録した内容がすでに入っていることを確認する
      expect(find('#prototype_title').value).to eq(@prototype1.title)
      expect(find('#prototype_catch_copy').value).to eq(@prototype1.catch_copy)
      expect(find('#prototype_concept').value).to eq(@prototype1.concept)
      # 情報を書き換える
      fill_in 'prototype_title', with: 'hoge'
      fill_in 'prototype_catch_copy', with: 'hoge1'
      fill_in 'prototype_concept', with: 'hoge2'
      click_on('保存する')
      sleep 1

      expect(current_path).to eq(prototype_path(@prototype1))
      expect(page).to have_selector('img')
      expect(page).to have_content('hoge')
      expect(page).to have_content('hoge1')
      expect(page).to have_content('hoge2')
    end
    
  end
  context '編集が失敗する時' do
    it '必要な情報を入力していない時' do
      sign_in(@user)
      visit prototype_path(@prototype1)
      expect(page).to have_link('編集する', href: edit_prototype_path(@prototype1))
      click_on('編集する')
      sleep 1
      expect(current_path).to eq(edit_prototype_path(@prototype1))
      # 登録した内容がすでに入っていることを確認する
      expect(find('#prototype_title').value).to eq(@prototype1.title)
      expect(find('#prototype_catch_copy').value).to eq(@prototype1.catch_copy)
      expect(find('#prototype_concept').value).to eq(@prototype1.concept)
      # 情報を書き換える
      fill_in 'prototype_title', with: ''
      fill_in 'prototype_catch_copy', with: ''
      fill_in 'prototype_concept', with: ''
      click_on('保存する')
      sleep 1

      expect(current_path).to eq(prototype_path(@prototype1))
    end

  end
end
RSpec.describe 'プロトタイプ削除機能', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @prototype1 = FactoryBot.create(:prototype, user: @user)
  end
  context '削除ができる場合' do
    it '削除が成功する時' do
      sign_in(@user)
      visit prototype_path(@prototype1)
      expect(page).to have_link('削除する', href: prototype_path(@prototype1))
      click_on('削除する')
      sleep 1
      expect(current_path).to eq(root_path)
    
      expect(page).to have_no_content(@prototype1.title)
      expect(page).to have_no_content(@prototype1.catch_copy)
      expect(page).to have_no_content(@prototype1.concept)
    end
  end
end



