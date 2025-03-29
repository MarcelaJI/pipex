NAME	= pipex
CC		= cc
CFLAGS	= -Wall -Wextra -Werror

LIBFT_DIR	= Libft
LIBFT_A		= $(LIBFT_DIR)/libft.a

SRCS	= mandatory/pipex.c \
		  mandatory/path.c \
		  mandatory/path_utils.c \
		  mandatory/parsing.c \
		  mandatory/parsing_utils.c \
		  mandatory/utils.c \
		  mandatory/processes.c

OBJS	= $(SRCS:.c=.o)

GREEN = \033[0;32m
RED = \033[1;31m
BLUE_UNDER = \033[1;34m
YELLOW = \033[0;33m
CYAN = \033[1;36m
MAGENTA = \033[0;35m
WHITE = \033[1;37m
WHITE_RED_BG = \033[0;41;37m
YELLOW_UNDER = \033[1;4;33m
NC = \033[0m

all: $(NAME)

$(LIBFT_A):
	@$(MAKE) -C $(LIBFT_DIR)

$(NAME): $(OBJS) $(LIBFT_A)
	@echo "$(MAGENTA)Compiling $(NAME)$(NC)"
	$(CC) $(CFLAGS) $(OBJS) -L$(LIBFT_DIR) -lft -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@echo "$(RED)Removing .o files in all directories$(NC)"
	rm -f $(OBJS) $(BOBJS)
	@$(MAKE) clean -C $(LIBFT_DIR)

fclean: clean
	@echo "$(RED)Removing .a files and executables$(NC)"
	rm -f $(NAME)
	@$(MAKE) fclean -C $(LIBFT_DIR)

re: fclean all
