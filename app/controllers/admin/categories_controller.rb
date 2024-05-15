class Admin::CategoriesController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :create, :destroy]
	before_action :set_category, only: [:edit, :update, :show, :destroy]

	def index
    @categories = Category.order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/categories/table", locals: { categories: @categories } }
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		if @category.update(secure_params)
			redirect_to admin_category_path(@category), flash_success_info: "Category details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Category details was not successfully updated."
		end
	end

	def destroy
		@category.destroy
		redirect_to admin_categories_path, flash_success_info: "Category was successfully deleted."
	end

	def new
		@category = Category.new
	end

	def create
    @category = Category.new(secure_params)
    if @category.save
      redirect_to admin_category_path(@category), flash_success_info: "Category was successfully created."
    else
    	flash[:flash_info] = "Category was not successfully created."
      render :new, status: :unprocessable_entity
    end
  end

	private

	def secure_params
		params.require(:category).permit(:name, :cover_photo)
	end

	def set_category
		@category = Category.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query, :status_filter) if params[:filters]
  end

end
