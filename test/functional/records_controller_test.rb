require 'test_helper'

class RecordsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Record.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Record.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Record.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to record_url(assigns(:record))
  end
  
  def test_edit
    get :edit, :id => Record.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Record.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Record.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Record.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Record.first
    assert_redirected_to record_url(assigns(:record))
  end
  
  def test_destroy
    record = Record.first
    delete :destroy, :id => record
    assert_redirected_to records_url
    assert !Record.exists?(record.id)
  end
end
