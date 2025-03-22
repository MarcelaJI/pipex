NAME	= pipex
CC		= cc
CFLAGS	= -Wall -Wextra -Werror

LIBFT_DIR	= Libft
LIBFT_A		= $(LIBFT_DIR)/libft.a

GNL		= get_next_line/get_next_line_bonus.c get_next_line/get_next_line_utils_bonus.c

SRCS	= mandatory/pipex.c \
		  mandatory/path.c \
		  mandatory/utils.c \
		  mandatory/processes.c \
	

BSRCS	= bonus/pipex_bonus.c \
		  bonus/path_bonus.c \
		  bonus/utils_bonus.c \
		  bonus/here_doc_bonus.c \
		  bonus/processes_bonus.c \
		  bonus/here_doc_utils_bonus.c \
		 

OBJS	= $(SRCS:.c=.o)
BOBJS	= $(BSRCS:.c=.o)

all: $(NAME)

$(LIBFT_A):
	@$(MAKE) -C $(LIBFT_DIR)

$(NAME): $(OBJS) $(LIBFT_A)
	$(CC) $(CFLAGS) $(OBJS) -L$(LIBFT_DIR) -lft -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

bonus: $(BOBJS) $(LIBFT_A)
	$(CC) $(CFLAGS) $(BOBJS) $(GNL) -L$(LIBFT_DIR) -lft -o $(NAME)

clean:
	rm -f $(OBJS) $(BOBJS)
	@$(MAKE) clean -C $(LIBFT_DIR)

fclean: clean
	rm -f $(NAME)
	@$(MAKE) fclean -C $(LIBFT_DIR)

re: fclean all
