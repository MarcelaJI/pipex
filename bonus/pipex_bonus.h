/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_bonus.h                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:20:54 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:21:00 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_BONUS_H
# define PIPEX_BONUS_H

# include "../Libft/libft.h"
# include "../get_next_line/get_next_line_bonus.h"
# include <errno.h>
# include <fcntl.h>
# include <stdbool.h>
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <sys/types.h>
# include <sys/wait.h>
# include <unistd.h>

# define READ_END 0
# define WRITE_END 1
# define HERE_DOC_TMP ".heredoc_tmp"

typedef struct s_cmd
{
	char	*origin_cmd;
	char	*path;
	char	**args;
}			t_cmd;

typedef struct s_pipex
{
	char	*infile;
	char	*outfile;
	int		number_cmds;
	int		here_doc;
	char	*limiter;
	int		**pipes;
	t_cmd	**cmds;
}			t_pipex;

int			pipex(int argc, char **argv, char **env);
void		child1(t_pipex *pipex, char **env, int i);
void		child2(t_pipex *pipex, char **env, int i);
void		middle_child(t_pipex *pipex, char **env, int i);
int			execute(t_cmd *cmd, char **env);
void		parse_cmds(t_pipex *pipex, char **av, char **env);
char		*check_direct_path(char *cmd_name);
char		*search_in_path(char *cmd_name, char **env);
char		*find_cmd_path(char *cmd_name, char **env);
char		*get_env_path(char **env);
char		*join_path(char *folder, char *cmd);
void		errors(int code, char *str);
void		free_pipex(t_pipex *pipex);
void		handle_here_doc(t_pipex *pipex);
void		create_pipes(t_pipex *pipex);
void		close_all_pipes(t_pipex *pipex);
void		wait_all(t_pipex *pipex);
void		init_pipex(t_pipex *px, int argc, char **argv);
void		launch_processes(t_pipex *px, char **env);
t_cmd		*create_cmd(char *arg, char **env, t_pipex *pipex);

#endif
