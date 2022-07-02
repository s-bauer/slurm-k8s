package cmd

import (
	"github.com/s-bauer/slurm-k8s/internal/installer"
	log "github.com/sirupsen/logrus"

	"github.com/spf13/cobra"
)

// installCmd represents the start command
var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Installs the required files",
	Run: func(cmd *cobra.Command, args []string) {
		if err := installer.Install(); err != nil {
			log.Fatal(err)
		}
	},
}

func init() {
	rootCmd.AddCommand(installCmd)
}
