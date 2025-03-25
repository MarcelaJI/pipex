/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils_bonus.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:21:36 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:21:42 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex_bonus.h"

void	create_pipes(t_pipex *pipex)
{
	int	i;

	pipex->pipes = malloc(sizeof(int *) * (pipex->number_cmds - 1));
	if (!pipex->pipes)
		errors(3, "malloc");
	i = 0;
	while (i < pipex->number_cmds - 1)
	{
		pipex->pipes[i] = malloc(sizeof(int) * 2);
		if (!pipex->pipes[i])
			errors(3, "malloc");
		if (pipe(pipex->pipes[i]) == -1)
			errors(5, NULL);
		i++;
	}
}

void	close_all_pipes(t_pipex *pipex)
{
	int	i;

	i = 0;
	while (i < pipex->number_cmds - 1)
	{
		close(pipex->pipes[i][READ_END]);
		close(pipex->pipes[i][WRITE_END]);
		i++;
	}
}

void	free_pipex(t_pipex *pipex)
{
	int	i;

	if (!pipex)
		return ;
	i = -1;
	if (pipex->cmds)
	{
		while (++i < pipex->number_cmds)
		{
			if (pipex->cmds[i])
			{
				ft_safe_free((void **)&pipex->cmds[i]->path);
				ft_safe_free((void **)&pipex->cmds[i]->origin_cmd);
				ft_free_split(pipex->cmds[i]->args);
				free(pipex->cmds[i]);
			}
		}
		free(pipex->cmds);
	}
	if (!pipex->pipes)
		return ;
	i = -1;
	while (++i < pipex->number_cmds - 1)
		free(pipex->pipes[i]);
	free(pipex->pipes);
}

void	errors(int code, char *str)
{
	if (code == 1)
	{
		ft_putendl_fd("Invalid format.", 2);
		ft_putendl_fd("./pipex [infile | here_doc LIMITER]", 2);
		ft_putendl_fd("cmd1 cmd2 ... outfile", 2);
	}
	if (code == 2 || code == 3)
	{
		perror(str);
		if (code == 2)
			return ;
	}
	if (code == 4)
	{
		ft_putstr_fd("Command not found: ", 2);
		if (str)
			ft_putendl_fd(str, 2);
		else
			ft_putendl_fd("(null)", 2);
	}
	if (code == 5)
		perror("Pipe or Dup Error");
}
