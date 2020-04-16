# frozen_string_literal: true

# == Schema Information
#
# Table name: articles
#
#  id         :integer          not null, primary key
#  title      :text
#  content    :text
#  category   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#  uuid       :string
#  slug       :string
#

class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  after_action :verify_authorized

  # GET /articles
  # GET /articles.json
  def index
    authorize Article # Pass in Model Class
    @articles = if current_user.is_admin?
                  Article.all.paginate(
                    page: params[:page],
                    per_page: params[:per_page] ||= 30
                  ).order(created_at: :desc)
                else
                  current_user.subscribed_articles.paginate(
                    page: params[:page],
                    per_page: params[:per_page] ||= 30
                  ).order(created_at: :desc)
    end

    respond_to do |format|
      format.json { render json: @articles, status: :ok }
      format.html {}
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    respond_to do |format|
      format.json { render json: @article }
      format.html { @article }
    end
  end

  # GET /articles/new
  def new
    authorize Article
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit; end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)
    authorize @article

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render json: @article, status: :created }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :bad_request }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { render json: @article, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :bad_request }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_path, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_article
    begin
      @article = Article.friendly.find(params[:id])
    rescue StandardError
      respond_to do |format|
        format.json { render status: 404, json: { alert: "The article you're looking for cannot be found" } }
        format.html { redirect_to articles_path, alert: "The article you're looking for cannot be found" }
      end
    end
    if @article.present?
      authorize @article # Pass in Model object
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def article_params
    params.require(:article).permit(:title, :content, :category, :user_id, :publication_id)
    # Students, make sure to add the user_id parameter as a symbol here ^^^^^^
  end
end
