/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_bonus.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:20:35 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:20:44 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex_bonus.h"

int	execute(t_cmd *cmd, char **env)
{
	if (!cmd || !cmd->path || !cmd->args)
		return (-1);
	if (access(cmd->path, X_OK) != 0)
		return (-1);
	execve(cmd->path, cmd->args, env);
	return (-1);
}

void	init_pipex(t_pipex *px, int argc, char **argv)
{
	ft_bzero(px, sizeof(t_pipex));
	if (ft_strncmp(argv[1], "here_doc", 9) == 0)
	{
		if (argc < 6)
			errors(1, NULL);
		px->here_doc = 1;
		px->limiter = argv[2];
		px->infile = HERE_DOC_TMP;
		px->outfile = argv[argc - 1];
		px->number_cmds = argc - 4;
	}
	else
	{
		px->here_doc = 0;
		px->infile = argv[1];
		px->outfile = argv[argc - 1];
		px->number_cmds = argc - 3;
	}
}

void	pipex(int argc, char **argv, char **env)
{
	t_pipex	pipex;

	init_pipex(&pipex, argc, argv);
	if (pipex.here_doc)
		handle_here_doc(&pipex);
	parse_cmds(&pipex, argv, env);
	create_pipes(&pipex);
	launch_processes(&pipex, env);
	close_all_pipes(&pipex);
	wait_all(&pipex);
}

int	main(int argc, char **argv, char **env)
{
	if (!env || !*env)
	{
		ft_putendl_fd("No environment found.", 2);
		exit(1);
	}
	if ((ft_strncmp(argv[1], "here_doc", 8) == 0 && argc < 6) || argc < 5)
	{
		errors(1, NULL);
		exit(1);
	}
	pipex(argc, argv, env);
}
