class JewelleryCategoriesController < ApplicationController
  def index
    @categories = JewelleryCategory.order(:name)
    render template: 'jewellery_categories/index'
  end

  def new
    @category = JewelleryCategory.new
    @metals = Metal.order(:name)
    render template: 'jewellery_categories/new'
  end

  def create
    @category = JewelleryCategory.new(category_params)
    if @category.save
      redirect_to jewellery_categories_path, notice: 'Category created.'
    else
      @metals = Metal.order(:name)
      render template: 'jewellery_categories/new'
    end
  end

  private
  def category_params
    params.require(:jewellery_category).permit(:metal_id, :name, :active)
  end
end
