# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  message    :text
#  visible    :boolean          default(FALSE)
#  article_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#  uuid       :string
#  slug       :string
#

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show edit update destroy]
  after_action :verify_authorized

  # GET /comments
  # GET /comments.json
  def index
    authorize Comment

    @comments = Comment.paginate(page: params[:page], per_page: params[:per_page] ||= 30).order(created_at: :desc)
    respond_to do |format|
      format.json { render json: Comment.all }
      format.html {}
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    respond_to do |format|
      format.json { render json: @comment }
      format.html { @comment }
    end
  end

  # GET /comments/new
  def new
    authorize Comment

    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit; end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    authorize @comment

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :bad_request }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render json: @comment, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :bad_request }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_path, notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    begin
      @comment = Comment.friendly.find(params[:id])
    rescue StandardError
      respond_to do |format|
        format.json { render status: 404, json: { alert: "The comment you're looking for cannot be found" } }
        format.html { redirect_to comments_path, alert: "The comment you're looking for cannot be found" }
      end
    end
    authorize @comment if @comment.present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:message, :visible, :article_id, :user_id)
    # Students, make sure to add the user_id and article ID parameter as symbols here ^^^^^^
  end
end
