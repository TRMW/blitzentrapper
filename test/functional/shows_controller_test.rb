require 'test_helper'

class ShowsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Show.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Show.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Show.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to show_url(assigns(:show))
  end
  
  def test_edit
    get :edit, :id => Show.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Show.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Show.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Show.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Show.first
    assert_redirected_to show_url(assigns(:show))
  end
  
  def test_destroy
    show = Show.first
    delete :destroy, :id => show
    assert_redirected_to shows_url
    assert !Show.exists?(show.id)
  end
end
