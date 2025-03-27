/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parsing_utils.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/27 09:36:35 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/27 09:36:40 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

t_cmd	*create_cmd_struct(char *cmd_str, char **env, t_pipex *pipex)
{
	t_cmd	*cmd;

	cmd = alloc_and_init_cmd(cmd_str, pipex);
	fill_cmd_args_and_path(cmd, env, pipex);
	return (cmd);
}

t_cmd	*alloc_and_init_cmd(char *cmd_str, t_pipex *pipex)
{
	t_cmd	*cmd;

	cmd = malloc(sizeof(t_cmd));
	if (!cmd)
	{
		errors(3, "malloc");
		free_pipex(pipex);
		exit(EXIT_FAILURE);
	}
	cmd->origin_cmd = ft_strdup(cmd_str);
	if (!cmd->origin_cmd)
	{
		errors(3, "malloc");
		free_pipex(pipex);
		exit(EXIT_FAILURE);
	}
	return (cmd);
}

void	fill_cmd_args_and_path(t_cmd *cmd, char **env, t_pipex *pipex)
{
	if (cmd->origin_cmd[0] == '\0')
	{
		cmd->args = NULL;
		cmd->path = NULL;
	}
	else
	{
		cmd->args = ft_split(cmd->origin_cmd, ' ');
		if (!cmd->args || !cmd->args[0])
		{
			errors(4, cmd->origin_cmd);
			free_pipex(pipex);
			exit(127);
		}
		cmd->path = find_cmd_path(cmd->args[0], env);
	}
}

t_pipex	*init_pipex_struct(int ac, char **av)
{
	t_pipex	*pipex;

	pipex = malloc(sizeof(t_pipex));
	if (!pipex)
	{
		errors(3, "malloc");
		exit(EXIT_FAILURE);
	}
	pipex->infile = av[1];
	pipex->outfile = av[ac - 1];
	pipex->number_cmds = ac - 3;
	pipex->cmds = malloc(sizeof(t_cmd *) * (pipex->number_cmds + 1));
	if (!pipex->cmds)
	{
		errors(3, "malloc");
		free_pipex(pipex);
		exit(EXIT_FAILURE);
	}
	return (pipex);
}
