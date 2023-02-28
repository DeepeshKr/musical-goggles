class Api::PostsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_api_v1_post, only: [:show, :update, :destroy]

  # GET /api/v1/posts
  def index
    @posts = Post.paginate(page: params[:page], per_page: 10)
    
    render json: {
      response: @posts,
      meta: pagination_dict(@posts)
    }
  end

  # GET /api/v1/posts/1
  def show
    render json: @api_v1_post
  end

  # POST /api/v1/posts
  def create
    @api_v1_post = Post.new(api_v1_post_params)

    if @api_v1_post.save
      render json: @api_v1_post, status: :created, location: @api_v1_post
    else
      render json: @api_v1_post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/posts/1
  def update
    if @api_v1_post.update(api_v1_post_params)
      render json: @api_v1_post
    else
      render json: @api_v1_post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/posts/1
  def destroy
    @api_v1_post.destroy
  end

  private
  def pagination_dict(posts)
    {
      current_page: posts.current_page,
      next_page: posts.next_page,
      prev_page: posts.previous_page,
      total_pages: posts.total_pages,
      total_count: posts.total_entries
    }
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_post
      @api_v1_post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_post_params
      params.require(:api_v1_post).permit(:title, :content)
    end
end
