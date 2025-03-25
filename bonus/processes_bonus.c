/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   processes_bonus.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:21:11 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:21:17 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex_bonus.h"

void	launch_processes(t_pipex *px, char **env)
{
	int	i;
	int	pid;

	i = -1;
	while (++i < px->number_cmds)
	{
		pid = fork();
		if (pid < 0)
			errors(5, NULL);
		if (pid == 0)
		{
			if (i == 0)
				child1(px, env, i);
			else if (i == px->number_cmds - 1)
				child2(px, env, i);
			else
				middle_child(px, env, i);
		}
	}
}

void	child1(t_pipex *px, char **env, int i)
{
	int	fd_in;

	if (px->here_doc)
		fd_in = open(HERE_DOC_TMP, O_RDONLY);
	else
		fd_in = open(px->infile, O_RDONLY);
	if (fd_in < 0)
	{
		errors(2, px->infile);
		free_pipex(px);
		exit(EXIT_FAILURE);
	}
	if (dup2(fd_in, STDIN_FILENO) < 0 || dup2(px->pipes[i][WRITE_END],
		STDOUT_FILENO) < 0)
	{
		errors(5, NULL);
		free_pipex(px);
		exit(EXIT_FAILURE);
	}
	close(fd_in);
	close_all_pipes(px);
	if (execute(px->cmds[i], env) < 0)
	{
		(errors(4, px->cmds[i]->origin_cmd), free_pipex(px), exit(127));
	}
}

void	middle_child(t_pipex *px, char **env, int i)
{
	if (dup2(px->pipes[i - 1][READ_END], STDIN_FILENO) < 0
		|| dup2(px->pipes[i][WRITE_END], STDOUT_FILENO) < 0)
		(errors(5, NULL), free_pipex(px), exit(EXIT_FAILURE));
	close_all_pipes(px);
	if (execute(px->cmds[i], env) < 0)
		(errors(4, px->cmds[i]->origin_cmd), free_pipex(px), exit(127));
}

void	child2(t_pipex *px, char **env, int i)
{
	int	fd_out;

	if (px->here_doc)
		fd_out = open(px->outfile, O_CREAT | O_APPEND | O_WRONLY, 0644);
	else
		fd_out = open(px->outfile, O_CREAT | O_TRUNC | O_WRONLY, 0644);
	if (fd_out < 0)
		(errors(2, px->outfile), free_pipex(px), exit(EXIT_FAILURE));
	if (dup2(px->pipes[i - 1][READ_END], STDIN_FILENO) < 0 || dup2(fd_out,
			STDOUT_FILENO) < 0)
		(errors(5, NULL), free_pipex(px), exit(EXIT_FAILURE));
	close(fd_out);
	close_all_pipes(px);
	if (execute(px->cmds[i], env) < 0)
		(errors(4, px->cmds[i]->origin_cmd), free_pipex(px), exit(127));
}

void	wait_all(t_pipex *pipex)
{
	int	status;
	int	i;

	i = 0;
	while (i < pipex->number_cmds)
	{
		wait(&status);
		i++;
	}
	if (pipex->here_doc == 1)
		unlink(HERE_DOC_TMP);
	free_pipex(pipex);
}
