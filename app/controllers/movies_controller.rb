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
    @date_class, @title_class = ''
    @all_ratings = Movie.get_ratings()
    sort = params[:sort] # Tells us which column to sort by
    commit = params[:commit]
    
    if sort == 'title'
      @movies = Movie.order(title: :asc)
      @title_class = 'hilite'
      if session[:params]
        session.delete(:params)
      end
      session[:params] = params
    elsif sort == 'release_date'
      @movies = Movie.order(release_date: :asc)
      @date_class = 'hilite'
      if session[:params]
        session.delete(:params)
      end
      session[:params] = params
    elsif commit == 'Refresh' && params[:ratings]
      ratings = params[:ratings]
      @movies = Movie.where(rating: ratings.keys)
      @selected_ratings = params[:ratings]
      
      #check appropriate ratings
      @all_ratings.each { |rating|
        if ratings.key?(rating)
          @checked.store(rating, true)
        else
          @checked.store(rating, false)
        end
      }
      if session[:params]
        session.delete(:params)
      end
      session[:params] = params
    elsif session[:params]
      puts session
      flash.keep
      redirect_to movies_path(:params => session[:params])
    else
      @movies = Movie.all
    
      #initialize the checked variables for when the page loads
      @all_ratings.each { |rating|
        @checked.store(rating, true)
      }
    end
    puts"SESSION INFO params: "
    puts session[:params]
    puts "/n/n/n"
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
