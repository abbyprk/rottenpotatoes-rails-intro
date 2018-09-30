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
    @all_ratings = Movie.get_ratings() #ask the Movie model for all applicable ratings
    
    #If we updated the params, then redirect
    if should_redirect
      flash.keep
      redirect_to movies_path(:params => params)
    else
      sort_and_filter
      @checked = get_checked_ratings(params[:ratings])
    end
  end
  
  # This method determines if any sorting or filtering criteria exists in the session 
  # that is not included in the query params. If so, it will update the
  # params and tell the caller that a redirect should be done
  def should_redirect
    session_params = session[:params]
    redirect = false
    
    # if the params do not contain ratings or sort criteria, then get it from the session params if it exists
    if !params[:ratings] && session_params && session_params["ratings"]
      params[:ratings] = session_params["ratings"]
      redirect = true
    end
    if !params[:sort] && session_params && session_params["sort"]
      params[:sort] = session_params["sort"]
      redirect = true
    end
    
    return redirect
  end
  
  # This method will sort and/or filter by the criteria in the params
  # If no params are set or the params contain invalid sorting information, it will return all movies
  def sort_and_filter
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
        #If an invalid option has somehow been selected or nothing is selected then show all movies
        @movies = Movie.all
      end
      
      session[:params] = params #Update session params with the latest criteria
  end
  
  # This method returns a hash with all ratings where true indicates 
  # that the rating has been selected
  def get_checked_ratings(ratings)
    checked = {}
    @all_ratings.each { |rating|
        if !ratings || ratings.key?(rating)
          checked.store(rating, true)
        else
          checked.store(rating, false)
        end
      }
    return checked
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
