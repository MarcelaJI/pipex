/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:19:14 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:19:17 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_H
# define PIPEX_H

# include "../Libft/libft.h"
# include <errno.h>
# include <fcntl.h>
# include <stdbool.h>
# include <stdio.h>
# include <string.h>
# include <sys/types.h>
# include <sys/wait.h>
# include <unistd.h>

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
	char	number_cmds;
	t_cmd	**cmds;
}			t_pipex;

int			pipex(int ac, char **av, char **env);
void		child1(t_pipex *pipex, char **env, int pipe_fd[2]);
void		child2(t_pipex *pipex, char **env, int pipe_fd[2]);
int			wait_childs(int pid1, int pid2, t_pipex *pipex);
int			execute(t_cmd *cmd, char **env);
void		parse_cmds(t_pipex *pipex, char **av, char **env);
char		*check_direct_path(char *cmd_name);
char		*search_in_path(char *cmd_name, char **env);
char		*find_cmd_path(char *cmd_name, char **env);
char		*get_env_path(char **env);
char		*join_path(char *folder, char *cmd);
void		errors(int code, char *str);
void		free_pipex(t_pipex *pipex);

#endif
