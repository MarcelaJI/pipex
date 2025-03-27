/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   processes.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:19:28 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:19:36 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

void	child1(t_pipex *pipex, char **env, int pipe_fd[2])
{
	int	in_fd;

	close(pipe_fd[0]);
	in_fd = open(pipex->infile, O_RDONLY);
	if (in_fd < 0)
	{
		(errors(2, pipex->infile), free_pipex(pipex), exit(EXIT_FAILURE));
	}
	if (dup2(in_fd, STDIN_FILENO) < 0)
	{
		(close(in_fd), free_pipex(pipex), exit(EXIT_FAILURE));
	}
	close(in_fd);
	if (dup2(pipe_fd[1], STDOUT_FILENO) < 0)
	{
		(close(pipe_fd[1]), free_pipex(pipex), exit(EXIT_FAILURE));
	}
	close(pipe_fd[1]);
	if (execute(pipex->cmds[0], env) < 0)
	{
		(errors(4, pipex->cmds[0]->origin_cmd), free_pipex(pipex), exit(127));
	}
}

void	child2(t_pipex *pipex, char **env, int pipe_fd[2])
{
	int	out_fd;

	close(pipe_fd[1]);
	out_fd = open(pipex->outfile, O_CREAT | O_TRUNC | O_WRONLY, 0644);
	if (out_fd < 0)
	{
		(errors(2, pipex->outfile), free_pipex(pipex));
		exit(EXIT_FAILURE);
	}
	if (dup2(out_fd, STDOUT_FILENO) < 0)
	{
		(close(out_fd), free_pipex(pipex), exit(EXIT_FAILURE));
	}
	close(out_fd);
	if (dup2(pipe_fd[0], STDIN_FILENO) < 0)
	{
		(close(pipe_fd[0]), free_pipex(pipex), exit(EXIT_FAILURE));
	}
	close(pipe_fd[0]);
	if (execute(pipex->cmds[pipex->number_cmds - 1], env) < 0)
	{
		errors(4, pipex->cmds[pipex->number_cmds - 1]->origin_cmd);
		free_pipex(pipex);
		exit(127);
	}
}

int	wait_childs(int pid1, int pid2, t_pipex *pipex)
{
	int	status;

	waitpid(pid1, NULL, 0);
	waitpid(pid2, &status, 0);
	free_pipex(pipex);
	return (WEXITSTATUS(status));
}
