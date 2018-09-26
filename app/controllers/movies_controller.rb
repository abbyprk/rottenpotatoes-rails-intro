class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @checked = {}
    @all_ratings = Movie.get_ratings()
    
    sort_filter = params[:sort] || params[:ratings] ||
                  (session[:params] && (session[:params].key?("sort") || session[:params].key?("ratings")))
    
    if sort_filter
      sort_and_filter(params)
    else
      @movies = Movie.all
    
      #initialize the checked variables for when the page loads without filter params
      @all_ratings.each { |rating|
        @checked.store(rating, true)
      }
    end
  end
  
  def sort_and_filter(params)
    session_params = session[:params]
    redirect = false
    
    # if the params do not contain ratings or sort, then get it from the session params if it exists
    if !params[:ratings] && session_params && session_params["ratings"]
      params[:ratings] = session_params["ratings"]
      redirect = true
    end
    if !params[:sort] && session_params && session_params["sort"]
      params[:sort] = session_params["sort"]
      redirect = true
    end
    
    #If we added to the params, then redirect with the updated params
    if redirect
      flash.keep
      redirect_to movies_path(:params => params)
    else
      @date_class, @title_class = ''

      if params[:sort] == 'title'
        @movies = params[:ratings] ? Movie.where(rating: params[:ratings].keys).order(title: :asc) : Movie.order(title: :asc)
        @title_class = 'hilite'
      elsif params[:sort] == 'release_date'
        @movies = params[:ratings] ? Movie.where(rating: params[:ratings].keys).order(release_date: :asc) : Movie.order(release_date: :asc)
        @date_class = 'hilite'
      elsif params[:ratings]
        @movies = Movie.where(rating: params[:ratings].keys)
      else
        @movies = Movie.all
      end
      
      session[:params] = params
      set_checked_ratings(params[:ratings])
    end
  end
  
  def set_checked_ratings(ratings)
    @all_ratings.each { |rating|
        if !ratings || ratings.key?(rating)
          @checked.store(rating, true)
        else
          @checked.store(rating, false)
        end
      }
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
