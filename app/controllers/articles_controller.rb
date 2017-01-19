class ArticlesController < ApplicationController
  helper_method :page, :per_page
  before_filter :require_contributor!, :only => [:new, :create, :edit, :update, :delete, :destroy]

  def require_contributor!
    unless true_user.is_contributor?
      redirect_to articles_path, notice: 'You aint qualified fool!'
    end
  end

  def index
    @articles = Article.where('publish_date <= ?', DateTime.now).order(created_at: :desc)
    @articles = @articles.paginate(:page => page, :per_page => per_page)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @articles, status: :ok, location: @articles }
    end
  end

  def show
    @article = Article.find_by_id(params[:id])

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @article, status: :ok, location: @article }
    end
  end

  def new
    @article = current_user.articles.new()
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @article, status: :created, location: @article }
    end
  end

  def create
    publish_date = params[:date]
    if publish_date.present?
      if publish_date[:day].present? && publish_date[:month].present? && publish_date[:year].present?
        article_publish_date = DateTime.strptime("#{publish_date[:year]} #{publish_date[:month]} #{publish_date[:day]}", "%Y %m %d")
        params[:article][:publish_date] = article_publish_date
      end
    end
    @article = current_user.articles.new(article_params)

    respond_to do |format|
      if @article.save
        @articles = Article.where('publish_date <= ?', DateTime.now).order(created_at: :desc)
        @articles = @articles.paginate(:page => page, :per_page => per_page)
        format.html { redirect_to articles_path, notice: 'Article was successfully created.' }
        format.js
        format.json { render json: @articles, status: :created, location: @articles }
      else
        format.html { render action: "new" }
        format.json { render json: @articles.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @article = Article.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @article, status: :ok, location: @article }
    end
  end

  def update
    @article = Article.find_by_id(params[:id])

    respond_to do |format|
      if @article.update_attributes(article_params)
        format.html { redirect_to articles_path, notice: 'Article was successfully created.' }
        format.js
        format.json { render json: @article, status: :ok, location: @article }
      else
        format.html { redirect_to articles_path, notice: 'Something went wrong' }
        format.js
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @article = Article.find_by_id(params[:article_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @article = Article.find_by_id(params[:id])
    @article.destroy
  end

  private
    def article_params
      params.require(:article).permit(:title, :body, :category, :publish_date)
    end

    def page
      (params[:page] || 1).to_i
    end

    def per_page
      (params[:per_page] || 20).to_i
    end

end
